-- Lácteos La Unión — restaurar selectores de barras
-- Este script modifica únicamente selection_config de estos dos SKU.
-- No cambia categorías, precios, nombres ni disponibilidad.

begin;

update public.products
set selection_config = '{
  "selectors": [
    {
      "id": "sel_dambo_tremblay",
      "options": [
        {"value": "0.5-barra", "label": "1/2 barra"},
        {"value": "1-barra", "label": "1 barra"},
        {"value": "2-barra", "label": "2 barras"}
      ]
    }
  ]
}'::jsonb,
updated_at = now()
where sku = 'quesos-semiduros_dambo_tremblay';

update public.products
set selection_config = '{
  "selectors": [
    {
      "id": "sel_cheddar_quesera_barra",
      "options": [
        {"value": "0.5-barra", "label": "1/2 barra"},
        {"value": "1-barra", "label": "1 barra"},
        {"value": "2-barra", "label": "2 barras"}
      ]
    }
  ]
}'::jsonb,
updated_at = now()
where sku = 'quesos-semiduros_cheddar_quesera_barra';

commit;

-- Verificación: deben aparecer ambos SKU y sus tres opciones.
select sku, name, category_id, selection_config
from public.products
where sku in (
  'quesos-semiduros_dambo_tremblay',
  'quesos-semiduros_cheddar_quesera_barra'
)
order by sku;
