-- Agrega selector de fracción de horma a los cuatro quesos por porción.
-- Conserva intactos los selectores de importe y peso y los precios.
update public.products set selection_config=jsonb_set(selection_config,'{selectors}',(selection_config->'selectors') || '[{"id":"sel_azul_horma","options":[{"value":"1/4","label":"1/4 de horma"},{"value":"1/2","label":"1/2 horma"},{"value":"3/4","label":"3/4 de horma"},{"value":"1","label":"1 horma"}]}]'::jsonb,true),updated_at=now() where sku='quesos-porcion_azul_monto';

update public.products set selection_config=jsonb_set(selection_config,'{selectors}',(selection_config->'selectors') || '[{"id":"sel_sardo_trem_horma","options":[{"value":"1/4","label":"1/4 de horma"},{"value":"1/2","label":"1/2 horma"},{"value":"3/4","label":"3/4 de horma"},{"value":"1","label":"1 horma"}]}]'::jsonb,true),updated_at=now() where sku='quesos-porcion_sardo_trem_monto';

update public.products set selection_config=jsonb_set(selection_config,'{selectors}',(selection_config->'selectors') || '[{"id":"sel_holanda_verona_horma","options":[{"value":"1/4","label":"1/4 de horma"},{"value":"1/2","label":"1/2 horma"},{"value":"3/4","label":"3/4 de horma"},{"value":"1","label":"1 horma"}]}]'::jsonb,true),updated_at=now() where sku='quesos-porcion_holanda_verona_monto';

update public.products set selection_config=jsonb_set(selection_config,'{selectors}',(selection_config->'selectors') || '[{"id":"sel_romanito_quesera_horma","options":[{"value":"1/4","label":"1/4 de horma"},{"value":"1/2","label":"1/2 horma"},{"value":"3/4","label":"3/4 de horma"},{"value":"1","label":"1 horma"}]}]'::jsonb,true),updated_at=now() where sku='quesos-porcion_romanito_quesera_monto';
