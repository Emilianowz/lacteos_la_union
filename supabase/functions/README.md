# Activar pedidos web en Supabase

La tienda pública guarda el pedido en Supabase antes de abrir WhatsApp. WhatsApp recibe únicamente el aviso de nuevo pedido.

## Despliegue de la Edge Function

Desde una terminal, en la carpeta raíz del repositorio:

```bash
supabase login
supabase link --project-ref mcldznfvurasijsmjrnp
supabase functions deploy create-public-order
```

El archivo `supabase/config.toml` configura `verify_jwt = false` para esta función, porque los clientes de la tienda no inician sesión. La función usa las variables de entorno administradas por Supabase (`SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY`) dentro del servidor. **No copies la clave service_role al HTML ni la compartas.**

Si se despliega desde el panel de Supabase, crear una Edge Function llamada `create-public-order`, pegar el contenido de `supabase/functions/create-public-order/index.ts` y desactivar la verificación JWT para esa función.

## Comportamiento

1. La página envía los datos del cliente y los artículos a la función.
2. La función registra el pedido y sus artículos en `orders` y `order_items`, con origen `web`.
3. Solo si el guardado termina correctamente, se abre WhatsApp con un aviso breve.
4. Si el guardado falla, no se envía el aviso y la tienda muestra un mensaje para reintentar.

Los artículos que requieren pesaje quedan con importe pendiente. El total registrado incluye los productos con precio definido y, si corresponde, el costo de envío.
