// Supabase Edge Function: create-public-order
// Deploy with: supabase functions deploy create-public-order
// Required secret: SUPABASE_SERVICE_ROLE_KEY (set in Supabase, never in the browser).

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "https://emilianowz.github.io",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json",
};

const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), { status, headers: corsHeaders });

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json(405, { error: "Método no permitido." });

  try {
    const body = await req.json();
    const name = String(body.customer_name ?? "").trim().slice(0, 120);
    const phone = String(body.customer_phone ?? "").trim().slice(0, 40);
    const deliveryType = body.delivery_type === "envio" ? "envio" : "retiro";
    const address = String(body.delivery_address ?? "").trim().slice(0, 300);
    const locality = String(body.delivery_locality ?? "San Lorenzo").trim().slice(0, 80);
    const normalizedLocality = locality.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
    if (deliveryType === "envio" && normalizedLocality !== "san lorenzo") {
      return json(400, { error: "Por el momento realizamos envíos únicamente dentro de San Lorenzo." });
    }
    const payment = ["efectivo", "transferencia", "debito"].includes(body.payment_method)
      ? body.payment_method : null;
    const items = Array.isArray(body.items) ? body.items : [];
    const isValidationRequest = body.action === "validate_commerce";
    const isQuoteRequest = body.action === "quote_delivery";

    if (!isQuoteRequest && (!name || !phone)) {
      return json(400, { error: "Ingresá nombre y teléfono." });
    }
    if (!isValidationRequest && !isQuoteRequest && (!payment || items.length === 0 || items.length > 100)) {
      return json(400, { error: "Faltan datos obligatorios o el pedido no contiene productos." });
    }
    if (deliveryType === "envio" && !address) {
      return json(400, { error: "Falta el domicilio de entrega." });
    }

    const cleanItems = items.map((item: Record<string, unknown>) => {
      const mode = ["unit", "weight", "portion", "sliced"].includes(String(item.sale_mode_snapshot))
        ? String(item.sale_mode_snapshot) : "unit";
      const quantity = Number(item.quantity);
      const lineTotal = item.line_total === null ? null : Number(item.line_total);
      const unitPrice = item.unit_price_snapshot === null ? null : Number(item.unit_price_snapshot);
      if (!String(item.product_name_snapshot ?? "").trim() || !Number.isFinite(quantity) || quantity <= 0 ||
          (lineTotal !== null && (!Number.isFinite(lineTotal) || lineTotal < 0)) ||
          (unitPrice !== null && (!Number.isFinite(unitPrice) || unitPrice < 0))) {
        throw new Error("Hay un producto con datos inválidos.");
      }
      const productId = item.product_id == null ? null : String(item.product_id);
      if (productId && !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(productId)) {
        throw new Error("Hay un producto con un identificador inválido.");
      }
      return {
        product_id: productId,
        product_name_snapshot: String(item.product_name_snapshot).slice(0, 180),
        sale_mode_snapshot: mode,
        unit_label_snapshot: String(item.unit_label_snapshot ?? "unidad").slice(0, 40),
        quantity,
        unit_price_snapshot: unitPrice,
        line_total: lineTotal,
        selection_details: item.selection_details && typeof item.selection_details === "object"
          ? item.selection_details : {},
      };
    });

    const mapsKey = Deno.env.get("GOOGLE_MAPS_API_KEY");
    const getDeliveryDistance = async (destination: string, destinationLocality: string): Promise<number> => {
      if (!mapsKey) throw new Error("Falta configurar GOOGLE_MAPS_API_KEY en Supabase.");
      const mapsResponse = await fetch("https://routes.googleapis.com/directions/v2:computeRoutes", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": mapsKey,
          "X-Goog-FieldMask": "routes.distanceMeters",
        },
        body: JSON.stringify({
          origin: { address: "Santiago del Estero 1047, San Lorenzo, Santa Fe, Argentina" },
          destination: { address: `${destination}, ${destinationLocality}, Santa Fe, Argentina` },
          travelMode: "DRIVE",
          routingPreference: "TRAFFIC_UNAWARE",
        }),
      });
      const mapsData = await mapsResponse.json().catch(() => ({}));
      if (!mapsResponse.ok) {
        console.error("Google Routes API:", mapsData);
        throw new Error("No pudimos ubicar el domicilio o calcular el recorrido. Revisá la dirección.");
      }
      const meters = Number(mapsData?.routes?.[0]?.distanceMeters);
      if (!Number.isFinite(meters) || meters <= 0) {
        throw new Error("Google Maps no encontró un recorrido válido para ese domicilio.");
      }
      return meters;
    };

    if (isQuoteRequest) {
      if (deliveryType !== "envio" || !address) {
        return json(400, { error: "Ingresá el domicilio para calcular el envío." });
      }
      const distanceMeters = await getDeliveryDistance(address, locality);
      const deliveryFee = Math.ceil(distanceMeters / 500) * 400;
      return json(200, { ok: true, distance_meters: distanceMeters, delivery_fee: deliveryFee });
    }

    const subtotal = cleanItems.reduce((sum, item) => sum + (item.line_total ?? 0), 0);
    const customerAddress = String(body.customer_address ?? "").trim().slice(0, 300);
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceKey) throw new Error("La función no está configurada en Supabase.");

    const db = createClient(supabaseUrl, serviceKey, { auth: { persistSession: false } });
    const productIds = [...new Set(cleanItems.flatMap((item) => item.product_id ? [item.product_id] : []))];
    if (productIds.length) {
      const { data: availableProducts, error: catalogError } = await db.from("products")
        .select("id,active").in("id", productIds);
      if (catalogError) throw catalogError;
      const activeProductIds = new Set((availableProducts || []).filter((product: any) => product.active).map((product: any) => product.id));
      if (productIds.some((id) => !activeProductIds.has(id))) {
        return json(409, { error: "Uno o más productos ya no están disponibles. Actualizá la página y volvé a armar el pedido." });
      }
    }
    const normalize = (value: string) => value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase().replace(/\s+/g, " ").trim();
    const digits = (value: string) => value.replace(/\D/g, "");
    let customerId: string | null = null;
    let isBusiness = false;
    if (body.customer_type === "comercio") {
      if (!customerAddress) return json(400, { error: "Ingresá el domicilio registrado del comercio." });
      const { data: businesses, error: customerError } = await db.from("customers")
        .select("id,name,phone,address").eq("customer_type", "comercio");
      if (customerError) throw customerError;
      const match = (businesses || []).find((c: any) =>
        normalize(c.name || "") === normalize(name) &&
        digits(c.phone || "") === digits(phone) &&
        normalize(c.address || "") === normalize(customerAddress)
      );
      if (!match) return json(403, { error: "No pudimos validar los datos del comercio. Revisá nombre, teléfono y domicilio o realizá el pedido como particular." });
      customerId = match.id;
      isBusiness = true;
    }
    if (isValidationRequest) {
      if (body.customer_type !== "comercio") {
        return json(400, { error: "La validación solicitada corresponde a un comercio." });
      }
      return json(200, {
        ok: true,
        authorized: isBusiness,
        benefit: isBusiness ? "5% de descuento y envío gratis" : null
      });
    }
    const discountPercent = isBusiness ? 5 : 0;
    const discountAmount = Number((subtotal * discountPercent / 100).toFixed(2));
    const deliveryDistance = deliveryType === "envio" && !isBusiness ? await getDeliveryDistance(address, locality) : 0;
    const deliveryFee = isBusiness || deliveryType !== "envio" ? 0 : Math.ceil(deliveryDistance / 500) * 400;
    const { data: order, error: orderError } = await db.from("orders").insert({
      customer_id: customerId,
      customer_name: name,
      customer_phone: phone,
      delivery_type: deliveryType,
      delivery_address: deliveryType === "envio" ? `${address}, ${locality}` : null,
      payment_method: payment,
      source: "web",
      status: "pedido_tomado",
      subtotal,
      discount_percent: discountPercent,
      discount_amount: discountAmount,
      delivery_fee: deliveryFee,
      total: subtotal - discountAmount + deliveryFee,
      notes: "",
    }).select("id,order_number").single();

    if (orderError) throw orderError;

    const { error: itemsError } = await db.from("order_items").insert(
      cleanItems.map(item => ({ ...item, order_id: order.id })),
    );
    if (itemsError) {
      await db.from("orders").delete().eq("id", order.id);
      throw itemsError;
    }

    await db.from("order_status_history").insert({
      order_id: order.id,
      previous_status: null,
      new_status: "pedido_tomado",
      changed_by: null,
      note: "Pedido recibido desde la tienda web",
    });

    return json(200, { ok: true, order_number: order.order_number });
  } catch (error) {
    console.error("create-public-order:", error);
    return json(400, { error: error instanceof Error ? error.message : "No se pudo guardar el pedido." });
  }
});
