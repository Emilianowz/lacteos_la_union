-- Actualiza únicamente las opciones de peso estimado de los cuatro quesos por porción.
-- No modifica precios ni opciones por importe; esas opciones se definirán por separado.

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,1,options}',
  '[{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"750","label":"750 gr"},{"value":"1000","label":"1 kg"},{"value":"1500","label":"1,5 kg"},{"value":"2000","label":"2 kg"},{"value":"2500","label":"2,5 kg"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_azul_monto';

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,1,options}',
  '[{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"750","label":"750 gr"},{"value":"1000","label":"1 kg"},{"value":"1500","label":"1,5 kg"},{"value":"2000","label":"2 kg"},{"value":"2500","label":"2,5 kg"},{"value":"3000","label":"3 kg"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_sardo_trem_monto';

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,1,options}',
  '[{"value":"500","label":"500 gr"},{"value":"1000","label":"1 kg"},{"value":"1500","label":"1,5 kg"},{"value":"2000","label":"2 kg"},{"value":"2500","label":"2,5 kg"},{"value":"3000","label":"3 kg"},{"value":"3500","label":"3,5 kg"},{"value":"4000","label":"4 kg"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_holanda_verona_monto';

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,1,options}',
  '[{"value":"1000","label":"1 kg"},{"value":"1500","label":"1,5 kg"},{"value":"2000","label":"2 kg"},{"value":"2500","label":"2,5 kg"},{"value":"3000","label":"3 kg"},{"value":"3500","label":"3,5 kg"},{"value":"4000","label":"4 kg"},{"value":"5000","label":"5 kg"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_romanito_quesera_monto';
