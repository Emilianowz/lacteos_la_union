-- Lácteos La Unión — actualización de precios noviembre 2026
-- Fuente: lista_precios_publico(3).pdf y exportación de catálogo 2026-11-11.csv
-- No modifica pedidos históricos, categorías, ni el estado activo/inactivo de productos.
-- Convierte los dos Por Salut porcionados a piezas pesables (precio por kg).
-- Agrega Provolone La Quesera a la categoría existente Quesos Por Porcion.
-- Ejecutar desde Supabase SQL Editor. Si algún precio anterior no coincide, aborta todo.

begin;

do $$
declare
  r record;
  changed integer;
begin
  for r in
    select * from (values
      ('8511bfd0-d33d-43ef-8d5f-78a7a7792e5c'::uuid, 'price'::text, 2200::numeric, 2250::numeric),
      ('de780889-325f-412b-90e7-ba9c610dca30'::uuid, 'price', 1800, 1850),
      ('23172caf-2556-42c9-ac62-9bda1ef331a5'::uuid, 'price', 1800, 1850),
      ('e2fcb649-c4e9-4659-9ad7-509bcd8ee16d'::uuid, 'price', 1800, 1850),
      ('83b7dba6-9267-4735-978b-b9c57d7725ec'::uuid, 'price', 1800, 1850),
      ('826a155c-bcb0-4d28-8396-3fbaf8e572eb'::uuid, 'price', 1800, 1850),
      ('71b80ea2-e328-452b-be5a-70c8e4d17f1b'::uuid, 'price', 1800, 1850),
      ('f94f62aa-48c7-48ec-a2a0-91d3cf9399a4'::uuid, 'price', 1800, 1850)
    ) as x(id, field_name, old_value, new_value)
  loop
    update public.products
       set price = r.new_value, updated_at = now()
     where id = r.id and price = r.old_value;
    get diagnostics changed = row_count;
    if changed <> 1 then
      raise exception 'No se actualizó el producto %: el precio anterior no coincide o el ID no existe.', r.id;
    end if;
  end loop;

  for r in
    select * from (values
      ('8b7fbb45-905a-4c2c-9652-332024372135'::uuid, 9000::numeric, 9054.91::numeric),
      ('a2e06539-8563-4e08-b8e9-65366707ee59'::uuid, 8750, 8800.27),
      ('56bfdb23-672f-4d82-91af-dc65288fc6bb'::uuid, 9000, 9071.78),
      ('4cca51bf-9fa0-4dda-af2a-cd8599f4e83e'::uuid, 12100, 12191.83),
      ('0aea4756-512f-40dc-982f-cc65485e557e'::uuid, 9200, 9268.45),
      ('332d604f-106b-4101-8db2-5e18f6441d9a'::uuid, 18850, 19655.40),
      ('09cb825c-e97b-44fa-b503-25cbe06f2c9d'::uuid, 25400, 25400.98),
      ('549acdbb-e4f4-4d68-a45e-ad1726f04d7e'::uuid, 25400, 25400.98),
      ('a153c1cc-8391-4e46-b55f-0eada85fc4c7'::uuid, 13950, 13967.63),
      ('f57b34d6-5b2a-4e66-a937-3ef2baefbaed'::uuid, 9800, 10226.32),
      ('09e59d58-c41a-40e2-8bae-b5fbdc11a72b'::uuid, 7500, 7813.20),
      ('2994287d-b46a-4394-82a3-ac45568a7ff2'::uuid, 13200, 13780.00),
      ('955767ec-71cd-4499-8664-322832a1fb47'::uuid, 24400, 25441.04),
      ('73facd36-3684-43bd-a66f-6f3ddc01c34a'::uuid, 18100, 18868.47),
      ('ba6d58f8-bbbc-41f0-9203-a88cac656bc3'::uuid, 17850, 18607.04),
      ('70ddf665-beb1-4fb7-9e98-d719f0bea6de'::uuid, 6050, 6327.50),
      ('59407572-4e86-4cbe-bedd-f9451207804d'::uuid, 20950, 21096.23)
    ) as x(id, old_value, new_value)
  loop
    update public.products
       set price_per_kg = r.new_value, updated_at = now()
     where id = r.id and price_per_kg = r.old_value;
    get diagnostics changed = row_count;
    if changed <> 1 then
      raise exception 'No se actualizó el precio por kg del producto %: el precio anterior no coincide o el ID no existe.', r.id;
    end if;
  end loop;

  -- Por Salut porcionados: se venden por pieza, pero se cobran por el peso real.
  update public.products
     set sale_mode = 'weight',
         unit_label = 'pieza',
         price = 0,
         price_per_kg = 9346.56,
         price_per_100g = null,
         selection_config = '{"quantity_stepper":true,"quantity_action":"weighted_piece"}'::jsonb,
         updated_at = now()
   where id = '419eb3e9-7b9f-49ed-a207-aec383ae664f'
     and sale_mode = 'unit' and price = 9250;
  get diagnostics changed = row_count;
  if changed <> 1 then raise exception 'No se pudo convertir Por Salut porcionado (con sal) a pieza pesable.'; end if;

  update public.products
     set sale_mode = 'weight',
         unit_label = 'pieza',
         price = 0,
         price_per_kg = 9986.23,
         price_per_100g = null,
         selection_config = '{"quantity_stepper":true,"quantity_action":"weighted_piece"}'::jsonb,
         updated_at = now()
   where id = '6fa7822a-e795-4246-8014-7579ba9caa68'
     and sale_mode = 'unit' and price = 9900;
  get diagnostics changed = row_count;
  if changed <> 1 then raise exception 'No se pudo convertir Por Salut porcionado sin sal a pieza pesable.'; end if;

  -- Provolone: nueva ficha en la categoría existente Quesos Por Porcion.
  if not exists (select 1 from public.products where sku = 'quesos-porcion_provolone_quesera') then
    insert into public.products
      (sku, category_id, name, description, sale_mode, unit_label, price,
       price_per_kg, price_per_100g, selection_config, sort_order, active)
    select
      'quesos-porcion_provolone_quesera',
      c.id,
      'PROVOLONE LA QUESERA x kg',
      '',
      'portion',
      'porción',
      0,
      29050,
      null,
      '{"selectors":[{"id":"sel_provolone_quesera_monto","options":[{"value":"5000","label":"$5.000"},{"value":"10000","label":"$10.000"},{"value":"15000","label":"$15.000"},{"value":"20000","label":"$20.000"},{"value":"30000","label":"$30.000"},{"value":"40000","label":"$40.000"}]},{"id":"sel_provolone_quesera_grs","options":[{"value":"250","label":"250 gr"},{"value":"500","label":"500 gr"},{"value":"750","label":"750 gr"},{"value":"1000","label":"1 kg"},{"value":"1500","label":"1,5 kg"},{"value":"2000","label":"2 kg"}]},{"id":"sel_provolone_quesera_horma","options":[{"value":"1/4","label":"1/4 de pieza"},{"value":"1/2","label":"1/2 pieza"},{"value":"3/4","label":"3/4 de pieza"},{"value":"1","label":"1 pieza"}]}]}'::jsonb,
      5,
      true
    from public.categories c
    where c.name = 'Quesos Por Porcion'
      and not exists (select 1 from public.products where sku = 'quesos-porcion_provolone_quesera');
    get diagnostics changed = row_count;
    if changed <> 1 then raise exception 'No se pudo insertar Provolone La Quesera: no se encontró la categoría o ya existe un conflicto.'; end if;
  end if;
end $$;

-- Comprobación antes de confirmar la transacción.
select name, sale_mode, unit_label, price, price_per_kg, active
from public.products
where id in (
  '419eb3e9-7b9f-49ed-a207-aec383ae664f',
  '6fa7822a-e795-4246-8014-7579ba9caa68'
)
or sku = 'quesos-porcion_provolone_quesera'
order by name;

select 'Productos con precios actualizados' as control, count(*) as cantidad
from public.products
where id in (
  '8511bfd0-d33d-43ef-8d5f-78a7a7792e5c',
  'de780889-325f-412b-90e7-ba9c610dca30',
  '23172caf-2556-42c9-ac62-9bda1ef331a5',
  'e2fcb649-c4e9-4659-9ad7-509bcd8ee16d',
  '83b7dba6-9267-4735-978b-b9c57d7725ec',
  '826a155c-bcb0-4d28-8396-3fbaf8e572eb',
  '71b80ea2-e328-452b-be5a-70c8e4d17f1b',
  'f94f62aa-48c7-48ec-a2a0-91d3cf9399a4',
  '8b7fbb45-905a-4c2c-9652-332024372135',
  'a2e06539-8563-4e08-b8e9-65366707ee59',
  '56bfdb23-672f-4d82-91af-dc65288fc6bb',
  '4cca51bf-9fa0-4dda-af2a-cd8599f4e83e',
  '0aea4756-512f-40dc-982f-cc65485e557e',
  '332d604f-106b-4101-8db2-5e18f6441d9a',
  '09cb825c-e97b-44fa-b503-25cbe06f2c9d',
  '549acdbb-e4f4-4d68-a45e-ad1726f04d7e',
  'a153c1cc-8391-4e46-b55f-0eada85fc4c7',
  'f57b34d6-5b2a-4e66-a937-3ef2baefbaed',
  '09e59d58-c41a-40e2-8bae-b5fbdc11a72b',
  '2994287d-b46a-4394-82a3-ac45568a7ff2',
  '955767ec-71cd-4499-8664-322832a1fb47',
  '73facd36-3684-43bd-a66f-6f3ddc01c34a',
  'ba6d58f8-bbbc-41f0-9203-a88cac656bc3',
  '70ddf665-beb1-4fb7-9e98-d719f0bea6de',
  '59407572-4e86-4cbe-bedd-f9451207804d'
);

-- Si las comprobaciones son correctas, ejecutar COMMIT; si no, ejecutar ROLLBACK;
-- COMMIT;
