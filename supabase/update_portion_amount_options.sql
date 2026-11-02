-- Actualiza únicamente las opciones de importe estimado de los cuatro quesos por porción.
-- No modifica precios por kg ni las opciones de peso estimado.

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,0,options}',
  '[{"value":"3000","label":"$3.000"},{"value":"6000","label":"$6.000"},{"value":"9000","label":"$9.000"},{"value":"12000","label":"$12.000"},{"value":"18000","label":"$18.000"},{"value":"24000","label":"$24.000"},{"value":"36000","label":"$36.000"},{"value":"48000","label":"$48.000"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_azul_monto';

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,0,options}',
  '[{"value":"3500","label":"$3.500"},{"value":"7000","label":"$7.000"},{"value":"10500","label":"$10.500"},{"value":"14000","label":"$14.000"},{"value":"21000","label":"$21.000"},{"value":"28000","label":"$28.000"},{"value":"35000","label":"$35.000"},{"value":"49000","label":"$49.000"},{"value":"66000","label":"$66.000"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_sardo_trem_monto';

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,0,options}',
  '[{"value":"4000","label":"$4.000"},{"value":"8000","label":"$8.000"},{"value":"12000","label":"$12.000"},{"value":"20000","label":"$20.000"},{"value":"28000","label":"$28.000"},{"value":"36000","label":"$36.000"},{"value":"54000","label":"$54.000"},{"value":"70000","label":"$70.000"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_holanda_verona_monto';

update public.products
set selection_config = jsonb_set(
  selection_config,
  '{selectors,0,options}',
  '[{"value":"5000","label":"$5.000"},{"value":"10000","label":"$10.000"},{"value":"15000","label":"$15.000"},{"value":"20000","label":"$20.000"},{"value":"30000","label":"$30.000"},{"value":"40000","label":"$40.000"},{"value":"60000","label":"$60.000"},{"value":"90000","label":"$90.000"},{"value":"120000","label":"$120.000"}]'::jsonb,
  true
), updated_at = now()
where sku = 'quesos-porcion_romanito_quesera_monto';
