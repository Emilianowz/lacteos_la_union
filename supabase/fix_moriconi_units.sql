-- Corrige la unidad de selección de los tres productos Moriconi.
-- Mantiene la modalidad por peso y el cálculo pendiente de pesaje;
-- solo cambia el texto de la cantidad seleccionada de "pieza" a "unidad".

update public.products
set unit_label = 'unidad',
    updated_at = now()
where sku in (
  'moriconi_salamin_pg_moriconi',
  'moriconi_salamin_pf_moriconi',
  'moriconi_chorizo_moriconi'
);
