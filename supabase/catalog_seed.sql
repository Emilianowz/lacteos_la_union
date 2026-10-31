-- Lácteos La Unión — carga inicial del catálogo
-- Fuente: catálogo vigente de index.html.
-- Incluye 11 categorías y 72 productos.
-- Importación idempotente: se puede ejecutar nuevamente sin duplicar SKU.
-- No elimina productos ajenos a este catálogo ni altera pedidos existentes.

begin;

insert into public.categories (name, sort_order, active)
values
  ('Quesos Blandos', 1),
  ('Quesos Semiduros', 2),
  ('Quesos Por Porcion', 3),
  ('Ralladitos', 4),
  ('Untables y Dulce de Leche', 5),
  ('Yogures y Leches', 6),
  ('Cremas y Mantecas', 7),
  ('Fiambres Piamontesa', 8),
  ('Cortado en Fetas', 9),
  ('Moriconi', 10),
  ('Snacks Crunch', 11)
on conflict (name) do update
set sort_order = excluded.sort_order,
    active = true,
    updated_at = now();

insert into public.products
  (sku, category_id, name, description, sale_mode, unit_label, price,
   price_per_kg, price_per_100g, selection_config, sort_order, active)
select
  v.sku,
  c.id,
  v.name,
  '',
  v.sale_mode::public.product_sale_mode,
  v.unit_label,
  v.price,
  v.price_per_kg,
  v.price_per_100g,
  v.selection_config,
  v.sort_order,
  true
from (values
  ('quesos-blandos_cuarti', 'Quesos Blandos', 'CUARTIROLO TREMBLAY (4 kg aprox.)', 'weight', 'horma', 0.00, 8750.00, NULL, '{"selectors":[{"id":"sel_cuarti","options":[{"value":"0.25","label":"1/4 horma"},{"value":"0.5","label":"1/2 horma"},{"value":"1","label":"1 horma"},{"value":"2","label":"2 hormas"}]}]}'::jsonb, 1),
  ('quesos-blandos_cremoso', 'Quesos Blandos', 'CREMOSO TREMBLAY (aprox. 4 kg)', 'weight', 'horma', 0.00, 9000.00, NULL, '{"selectors":[{"id":"sel_cremoso","options":[{"value":"0.25","label":"1/4 horma"},{"value":"0.5","label":"1/2 horma"},{"value":"1","label":"1 horma"},{"value":"2","label":"2 hormas"}]}]}'::jsonb, 2),
  ('quesos-blandos_portsalut', 'Quesos Blandos', 'POR SALUT TREMBLAY (aprox. 3,2 kg)', 'weight', 'horma', 0.00, 9000.00, NULL, '{"selectors":[{"id":"sel_portsalut","options":[{"value":"0.25","label":"1/4 horma"},{"value":"0.5","label":"1/2 horma"},{"value":"1","label":"1 horma"},{"value":"2","label":"2 hormas"}]}]}'::jsonb, 3),
  ('quesos-blandos_portsalut_porcionado', 'Quesos Blandos', 'POR SALUT TREMBLAY PORCIONADO (400 g aprox.) x unidad', 'unit', 'unidad', 9250.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 4),
  ('quesos-blandos_portsalut_ss_porcionado', 'Quesos Blandos', 'POR SALUT SIN SAL TREMBLAY PORCIONADO (400 g aprox.) x unidad', 'unit', 'unidad', 9900.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 5),
  ('quesos-blandos_pasta_azul_quesera_pouch', 'Quesos Blandos', 'PASTA AZUL LA QUESERA POUCH 4 kg x unidad', 'unit', 'unidad', 16950.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 6),
  ('quesos-blandos_cheddar_untar_pouch', 'Quesos Blandos', 'QUESO CHEDDAR PARA UNTAR POUCH 4 kg x unidad', 'unit', 'unidad', 12350.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 7),
  ('quesos-semiduros_dambo_tremblay', 'Quesos Semiduros', 'BARRA DAMBO TREMBLAY (4 kg aprox.) x kg', 'weight', 'barra', 0.00, 11500.00, NULL, '{"selectors":[{"id":"sel_dambo_tremblay","options":[{"value":"0.5-barra","label":"1/2 barra"},{"value":"1-barra","label":"1 barra"},{"value":"2-barra","label":"2 barras"}]}]}'::jsonb, 1),
  ('quesos-semiduros_cheddar_quesera_barra', 'Quesos Semiduros', 'BARRA CHEDDAR LA QUESERA (2,9 kg) x kg', 'weight', 'barra', 0.00, 21750.00, NULL, '{"selectors":[{"id":"sel_cheddar_quesera_barra","options":[{"value":"0.5-barra","label":"1/2 barra"},{"value":"1-barra","label":"1 barra"},{"value":"2-barra","label":"2 barras"}]}]}'::jsonb, 2),
  ('quesos-semiduros_muzz_barra', 'Quesos Semiduros', 'MUZZARELLA TREMBLAY BARRA (aprox. 4 kg)', 'weight', 'barra', 0.00, 12100.00, NULL, '{"selectors":[{"id":"sel_muzz_barra","options":[{"value":"0.5","label":"1/2 barra"},{"value":"1","label":"1 barra"},{"value":"2","label":"2 barras"}]}]}'::jsonb, 3),
  ('quesos-semiduros_muzz_cilindro', 'Quesos Semiduros', 'MUZZARELLA TREMBLAY CILINDRO (5 kg completo)', 'weight', 'barra', 0.00, 9200.00, NULL, '{"quantity_stepper":true,"quantity_action":"weighted_piece"}'::jsonb, 4),
  ('quesos-porcion_azul_monto', 'Quesos Por Porcion', 'QUESO AZUL LA QUESERA (aprox. 2,4 kg)', 'portion', 'porción', 0.00, 20050.00, NULL, '{"selectors":[{"id":"sel_azul_monto","options":[{"value":"1000","label":"$1.000"},{"value":"1500","label":"$1.500"},{"value":"2000","label":"$2.000"},{"value":"2500","label":"$2.500"},{"value":"3000","label":"$3.000"},{"value":"5000","label":"$5.000"}]},{"id":"sel_azul_grs","options":[{"value":"100","label":"100 gr"},{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"1000","label":"1 kg"}]}]}'::jsonb, 1),
  ('quesos-porcion_sardo_trem_monto', 'Quesos Por Porcion', 'SARDO TREMBLAY (3,200 kg aprox.) x kg', 'portion', 'porción', 0.00, 20950.00, NULL, '{"selectors":[{"id":"sel_sardo_trem_monto","options":[{"value":"1000","label":"$1.000"},{"value":"1500","label":"$1.500"},{"value":"2000","label":"$2.000"},{"value":"2500","label":"$2.500"},{"value":"3000","label":"$3.000"},{"value":"5000","label":"$5.000"}]},{"id":"sel_sardo_trem_grs","options":[{"value":"100","label":"100 gr"},{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"1000","label":"1 kg"}]}]}'::jsonb, 2),
  ('quesos-porcion_holanda_verona_monto', 'Quesos Por Porcion', 'HOLANDA LA VERONA x kg', 'portion', 'porción', 0.00, 18850.00, NULL, '{"selectors":[{"id":"sel_holanda_verona_monto","options":[{"value":"1000","label":"$1.000"},{"value":"1500","label":"$1.500"},{"value":"2000","label":"$2.000"},{"value":"2500","label":"$2.500"},{"value":"3000","label":"$3.000"},{"value":"5000","label":"$5.000"}]},{"id":"sel_holanda_verona_grs","options":[{"value":"100","label":"100 gr"},{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"1000","label":"1 kg"}]}]}'::jsonb, 3),
  ('quesos-porcion_romanito_quesera_monto', 'Quesos Por Porcion', 'ROMANITO S/P LA QUESERA (5 kg aprox.) x kg', 'portion', 'porción', 0.00, 27300.00, NULL, '{"selectors":[{"id":"sel_romanito_quesera_monto","options":[{"value":"1000","label":"$1.000"},{"value":"1500","label":"$1.500"},{"value":"2000","label":"$2.000"},{"value":"2500","label":"$2.500"},{"value":"3000","label":"$3.000"},{"value":"5000","label":"$5.000"}]},{"id":"sel_romanito_quesera_grs","options":[{"value":"100","label":"100 gr"},{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"1000","label":"1 kg"}]}]}'::jsonb, 4),
  ('ralladitos_sancor40', 'Ralladitos', 'RALLADO SANCOR × 40gr', 'unit', 'unidad', 1750.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 1),
  ('ralladitos_paulina40', 'Ralladitos', 'RALLADO LA PAULINA × 40gr', 'unit', 'unidad', 1450.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 2),
  ('ralladitos_quesera40', 'Ralladitos', 'RALLADO LA QUESERA × 40gr', 'unit', 'unidad', 850.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 3),
  ('ralladitos_quesera150', 'Ralladitos', 'RALLADO LA QUESERA × 150gr', 'unit', 'unidad', 3200.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 4),
  ('untables_unt_clas', 'Untables y Dulce de Leche', 'UNTABLE CLÁSICO TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 1),
  ('untables_unt_ps', 'Untables y Dulce de Leche', 'UNTABLE POR SALUT TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 2),
  ('untables_unt_jamon', 'Untables y Dulce de Leche', 'UNTABLE JAMÓN TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 3),
  ('untables_unt_azul', 'Untables y Dulce de Leche', 'UNTABLE AZUL TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 4),
  ('untables_unt_cheddar', 'Untables y Dulce de Leche', 'UNTABLE CHEDDAR TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 5),
  ('untables_unt_finas', 'Untables y Dulce de Leche', 'UNTABLE FINAS HIERBAS TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 6),
  ('untables_unt_salame', 'Untables y Dulce de Leche', 'UNTABLE SALAME TREMBLAY × 190gr', 'unit', 'unidad', 1800.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 7),
  ('untables_qc_trem_clas', 'Untables y Dulce de Leche', 'QUESO CREMA TREMBLAY CLÁSICO x 290 grs', 'unit', 'unidad', 3350.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 8),
  ('untables_qc_trem_light', 'Untables y Dulce de Leche', 'QUESO CREMA TREMBLAY LIGHT x 290 grs', 'unit', 'unidad', 3350.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 9),
  ('untables_qc_trem_pouch', 'Untables y Dulce de Leche', 'QUESO CREMA TREMBLAY POUCH x 3 kg (x unidad)', 'unit', 'unidad', 24500.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 10),
  ('untables_qc_quesera_clas', 'Untables y Dulce de Leche', 'QUESO CREMA LA QUESERA CLÁSICO x 290 g', 'unit', 'unidad', 2600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 11),
  ('untables_qc_quesera_light', 'Untables y Dulce de Leche', 'QUESO CREMA LA QUESERA LIGHT x 290 g', 'unit', 'unidad', 2600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 12),
  ('untables_ddl_trem_250', 'Untables y Dulce de Leche', 'DULCE DE LECHE TREMBLAY x 250 grs', 'unit', 'unidad', 1400.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 13),
  ('untables_ddl_trem_400', 'Untables y Dulce de Leche', 'DULCE DE LECHE TREMBLAY x 400 grs', 'unit', 'unidad', 2150.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 14),
  ('untables_ddl_trem_repost', 'Untables y Dulce de Leche', 'DULCE DE LECHE TREMBLAY REPOSTERO x 500 grs', 'unit', 'unidad', 2200.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 15),
  ('untables_ddl_sancor_400', 'Untables y Dulce de Leche', 'DULCE DE LECHE SANCOR x 400 grs', 'unit', 'unidad', 3350.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 16),
  ('yogures-leches_yog_vainilla', 'Yogures y Leches', 'YOGUR VAINILLA TREMBLAY x 900 grs', 'unit', 'unidad', 1600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 1),
  ('yogures-leches_yog_frutilla', 'Yogures y Leches', 'YOGUR FRUTILLA TREMBLAY x 900 grs', 'unit', 'unidad', 1600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 2),
  ('yogures-leches_yog_durazno', 'Yogures y Leches', 'YOGUR DURAZNO TREMBLAY x 900 grs', 'unit', 'unidad', 1600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 3),
  ('yogures-leches_leche_sancor_ent', 'Yogures y Leches', 'LECHE LARGA VIDA SANCOR ENTERA x 1 lt', 'unit', 'unidad', 1900.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 4),
  ('cremas-mantecas_crema_trem_200', 'Cremas y Mantecas', 'CREMA DE LECHE TREMBLAY x 200 grs', 'unit', 'unidad', 1950.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 1),
  ('cremas-mantecas_crema_trem_360', 'Cremas y Mantecas', 'CREMA DE LECHE TREMBLAY x 360 grs', 'unit', 'unidad', 3300.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 2),
  ('cremas-mantecas_crema_sancor_200', 'Cremas y Mantecas', 'CREMA DE LECHE SANCOR x 200 grs', 'unit', 'unidad', 2200.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 3),
  ('cremas-mantecas_crema_sancor_360', 'Cremas y Mantecas', 'CREMA DE LECHE SANCOR x 360 grs', 'unit', 'unidad', 3600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 4),
  ('cremas-mantecas_manteca_sancor_100', 'Cremas y Mantecas', 'MANTECA SANCOR x 100 grs', 'unit', 'unidad', 2000.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 5),
  ('cremas-mantecas_manteca_sancor_200', 'Cremas y Mantecas', 'MANTECA SANCOR x 200 grs', 'unit', 'unidad', 3750.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 6),
  ('fiambres_paleta_piamontesa', 'Fiambres Piamontesa', 'PALETA DE CERDO PIAMONTESA (5 kg aprox.) x kg', 'weight', 'pieza', 0.00, 9800.00, NULL, '{"selectors":[{"id":"sel_paleta_piamontesa","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 1),
  ('fiambres_paleta_131', 'Fiambres Piamontesa', 'PALETA DE CERDO 131 (5 kg aprox.) x kg', 'weight', 'pieza', 0.00, 7500.00, NULL, '{"selectors":[{"id":"sel_paleta_131","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 2),
  ('fiambres_jamon_piamontesa', 'Fiambres Piamontesa', 'JAMÓN COCIDO FIAM. PIAMONTESA (3 kg aprox.) x kg', 'weight', 'pieza', 0.00, 13200.00, NULL, '{"selectors":[{"id":"sel_jamon_piamontesa","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 3),
  ('fiambres_bondiola_piamontesa', 'Fiambres Piamontesa', 'BONDIOLA PIAMONTESA (1 kg aprox.) x kg', 'weight', 'pieza', 0.00, 24400.00, NULL, '{"selectors":[{"id":"sel_bondiola_piamontesa","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 4),
  ('fiambres_salame_mt_piamontesa', 'Fiambres Piamontesa', 'SALAME x MT. PIAMONTESA P/G (900 g) x kg', 'weight', 'pieza', 0.00, 18100.00, NULL, '{"selectors":[{"id":"sel_salame_mt_piamontesa","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 5),
  ('fiambres_salame_crespon', 'Fiambres Piamontesa', 'SALAME P/G TIPO CRESPÓN PIAMONTESA (1,8 kg aprox.)', 'weight', 'pieza', 0.00, 17850.00, NULL, '{"selectors":[{"id":"sel_salame_crespon","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 6),
  ('fiambres_salchichon_verd', 'Fiambres Piamontesa', 'SALCHICHÓN C/VERD PIAMONTESA (2,5 kg) x kg', 'weight', 'pieza', 0.00, 6050.00, NULL, '{"selectors":[{"id":"sel_salchichon_verd","options":[{"value":"0.5-pieza","label":"1/2 pieza"},{"value":"1-pieza","label":"1 pieza"},{"value":"2-pieza","label":"2 piezas"}]}]}'::jsonb, 7),
  ('cortado-fetas_fetas_danbo', 'Cortado en Fetas', 'QUESO DANBO TREMBLAY', 'sliced', '100 g', 0.00, NULL, 1300.00, '{"selectors":[{"id":"fetas_danbo","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 1),
  ('cortado-fetas_fetas_paleta_piamontesa', 'Cortado en Fetas', 'PALETA DE CERDO PIAMONTESA', 'sliced', '100 g', 0.00, NULL, 1250.00, '{"selectors":[{"id":"fetas_paleta_piamontesa","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 2),
  ('cortado-fetas_fetas_paleta_131', 'Cortado en Fetas', 'PALETA DE CERDO 131', 'sliced', '100 g', 0.00, NULL, 950.00, '{"selectors":[{"id":"fetas_paleta_131","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 3),
  ('cortado-fetas_fetas_jamon_piamontesa', 'Cortado en Fetas', 'JAMÓN COCIDO PIAMONTESA', 'sliced', '100 g', 0.00, NULL, 1650.00, '{"selectors":[{"id":"fetas_jamon_piamontesa","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 4),
  ('cortado-fetas_fetas_salchichon', 'Cortado en Fetas', 'SALCHICHÓN C/VERD PIAMONTESA', 'sliced', '100 g', 0.00, NULL, 750.00, '{"selectors":[{"id":"fetas_salchichon","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 5),
  ('cortado-fetas_fetas_bondiola', 'Cortado en Fetas', 'BONDIOLA PIAMONTESA', 'sliced', '100 g', 0.00, NULL, 3050.00, '{"selectors":[{"id":"fetas_bondiola","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 6),
  ('cortado-fetas_fetas_salame_crespon', 'Cortado en Fetas', 'SALAME TIPO CRESPÓN PIAMONTESA', 'sliced', '100 g', 0.00, NULL, 2250.00, '{"selectors":[{"id":"fetas_salame_crespon","options":[{"value":"50","label":"50 g"},{"value":"100","label":"100 g"},{"value":"150","label":"150 g"},{"value":"200","label":"200 g"},{"value":"250","label":"250 g"},{"value":"300","label":"300 g"},{"value":"400","label":"400 g"},{"value":"500","label":"500 g"}]}]}'::jsonb, 7),
  ('moriconi_salamin_pg_moriconi', 'Moriconi', 'SALAMÍN P/G MORICONI (700 grs aprox.) x kg', 'weight', 'pieza', 0.00, 25400.00, NULL, '{"quantity_stepper":true,"quantity_action":"weighted_piece"}'::jsonb, 1),
  ('moriconi_salamin_pf_moriconi', 'Moriconi', 'SALAMÍN P/F MORICONI (700 grs aprox.) x kg', 'weight', 'pieza', 0.00, 25400.00, NULL, '{"quantity_stepper":true,"quantity_action":"weighted_piece"}'::jsonb, 2),
  ('moriconi_chorizo_moriconi', 'Moriconi', 'CHORIZO MORICONI (6 kg aprox.) x kg', 'weight', 'pieza', 0.00, 13950.00, NULL, '{"quantity_stepper":true,"quantity_action":"weighted_piece"}'::jsonb, 3),
  ('snacks-crunch_papas_clas_20', 'Snacks Crunch', 'PAPITAS CLÁSICAS × 20g', 'unit', 'unidad', 750.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 1),
  ('snacks-crunch_papas_clas_34', 'Snacks Crunch', 'PAPITAS CLÁSICAS × 34g', 'unit', 'unidad', 1300.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 2),
  ('snacks-crunch_papas_clas_80', 'Snacks Crunch', 'PAPITAS CLÁSICAS × 80g', 'unit', 'unidad', 2150.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 3),
  ('snacks-crunch_papas_clas_150', 'Snacks Crunch', 'PAPITAS CLÁSICAS × 150g', 'unit', 'unidad', 3500.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 4),
  ('snacks-crunch_papas_clas_250', 'Snacks Crunch', 'PAPITAS CLÁSICAS × 250g', 'unit', 'unidad', 4250.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 5),
  ('snacks-crunch_papas_jamon_90', 'Snacks Crunch', 'PAPITAS JAMÓN × 90g', 'unit', 'unidad', 2450.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 6),
  ('snacks-crunch_papas_crema_90', 'Snacks Crunch', 'PAPITAS CREMA Y CEBOLLA × 90g', 'unit', 'unidad', 2450.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 7),
  ('snacks-crunch_pipitas_guacamole_90', 'Snacks Crunch', 'PAPITAS FRITAS GUACAMOLE x 90g', 'unit', 'unidad', 2450.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 8),
  ('snacks-crunch_mani_pelado_100', 'Snacks Crunch', 'MANI PELADO x 100g', 'unit', 'unidad', 1600.00, NULL, NULL, '{"quantity_stepper":true,"quantity_action":"unit"}'::jsonb, 9),
  ('snacks-crunch_entrega', 'Snacks Crunch', 'PALITOS FRITOS x 80g', 'unit', 'unidad', 1600.00, NULL, NULL, '{"selectors":[{"id":"entrega","options":[{"value":"retiro","label":"Retirar en Santiago del Estero 1047 — Gratis"},{"value":"envio","label":"Envío a domicilio — $1.500"}]},{"id":"pago","options":[{"value":"efectivo","label":"Efectivo"},{"value":"transferencia","label":"Transferencia"},{"value":"debito","label":"Débito"}]}]}'::jsonb, 10)
) as v(sku, category_name, name, sale_mode, unit_label, price, price_per_kg, price_per_100g, selection_config, sort_order)
join public.categories c on c.name = v.category_name
on conflict (sku) do update set
  category_id = excluded.category_id,
  name = excluded.name,
  description = excluded.description,
  sale_mode = excluded.sale_mode,
  unit_label = excluded.unit_label,
  price = excluded.price,
  price_per_kg = excluded.price_per_kg,
  price_per_100g = excluded.price_per_100g,
  selection_config = excluded.selection_config,
  sort_order = excluded.sort_order,
  active = true,
  updated_at = now();

commit;

-- Verificación posterior:
select c.name as categoria, count(p.id) as productos
from public.categories c
left join public.products p on p.category_id = c.id and p.active = true
group by c.id, c.name, c.sort_order
order by c.sort_order;
