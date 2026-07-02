-- ════════════════════════════════════════════════════════
-- Blox Pets — tabelas para o painel Admin (Supabase)
-- Rode este script no SQL Editor do seu projeto Supabase
-- (jsyiriqtzpbuqvjrkwin.supabase.co). Não mexe em nenhuma
-- tabela existente de outros projetos (contratos, clientes, etc).
-- ════════════════════════════════════════════════════════

create table if not exists public.bp_pets (
  id bigint generated always as identity primary key,
  name text not null,
  desc text not null default '',
  price numeric not null default 0,
  rarity text not null default 'comum',
  avail smallint not null default 1,
  "isNew" smallint not null default 0,
  img text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.bp_contas (
  id bigint generated always as identity primary key,
  name text not null,
  desc text not null default '',
  price numeric not null default 0,
  tags text[] not null default '{}',
  avail smallint not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.bp_gamepasses (
  id bigint generated always as identity primary key,
  name text not null,
  desc text not null default '',
  price numeric not null default 0,
  icon text not null default '🎟️',
  avail smallint not null default 1,
  created_at timestamptz not null default now()
);

create table if not exists public.bp_faqs (
  id bigint generated always as identity primary key,
  q text not null,
  a text not null,
  created_at timestamptz not null default now()
);

-- ── RLS ──
-- O app não tem autenticação real (a senha do admin é só uma checagem
-- no JavaScript da página). Por isso as políticas abaixo liberam leitura
-- e escrita públicas nessas 4 tabelas — qualquer pessoa com a anon key
-- (visível no código-fonte da página) pode ler e escrever nelas.
-- Isso é equivalente ao nível de segurança que o site já tinha antes
-- (senha só no cliente). Se quiser travar melhor no futuro, dá pra
-- validar a senha em uma Supabase Edge Function.
alter table public.bp_pets enable row level security;
alter table public.bp_contas enable row level security;
alter table public.bp_gamepasses enable row level security;
alter table public.bp_faqs enable row level security;

drop policy if exists "public rw bp_pets" on public.bp_pets;
create policy "public rw bp_pets" on public.bp_pets for all using (true) with check (true);

drop policy if exists "public rw bp_contas" on public.bp_contas;
create policy "public rw bp_contas" on public.bp_contas for all using (true) with check (true);

drop policy if exists "public rw bp_gamepasses" on public.bp_gamepasses;
create policy "public rw bp_gamepasses" on public.bp_gamepasses for all using (true) with check (true);

drop policy if exists "public rw bp_faqs" on public.bp_faqs;
create policy "public rw bp_faqs" on public.bp_faqs for all using (true) with check (true);

-- ── SEED (dados que já estavam no site, só roda se as tabelas estiverem vazias) ──
insert into public.bp_pets (id, name, desc, price, rarity, avail, "isNew", img) overriding system value
select * from (values
  (1,'Básico','Um brainrot surpresa para começar!',4.99,'comum',1,0,''),
  (2,'Intermediário','Chance de pets raros incluída.',15.00,'raro',1,0,''),
  (3,'Avançado','Grandes chances de épicos.',44.99,'epico',1,1,''),
  (4,'Supremo','Lendários garantidos na mistura.',59.99,'lendario',1,0,''),
  (5,'Divino','O topo absoluto. Ultra raro.',99.99,'divino',1,1,'')
) as v(id,name,desc,price,rarity,avail,"isNew",img)
where not exists (select 1 from public.bp_pets);

insert into public.bp_contas (id, name, desc, price, tags, avail) overriding system value
select 1,'Conta Gold','Conta com vários itens raros e combinações exclusivas.',89.99,array['Lendário','Raro'],1
where not exists (select 1 from public.bp_contas);

insert into public.bp_gamepasses (id, name, desc, price, icon, avail) overriding system value
select 1,'VIP Pass','Acesso VIP com benefícios exclusivos dentro do jogo.',29.99,'🎟️',1
where not exists (select 1 from public.bp_gamepasses);

insert into public.bp_faqs (id, q, a) overriding system value
select * from (values
  (1,'Como recebo meu pet?','A entrega é feita por troca dentro do próprio jogo. Após o pagamento, entre em contato pelo WhatsApp.'),
  (2,'Qual o prazo de entrega?','Até 1 hora dentro do horário de funcionamento.'),
  (3,'É seguro comprar?','Sim! Todos os nossos pedidos são entregues pessoalmente dentro do jogo. Nenhuma informação da conta é solicitada.'),
  (4,'Aceitam quais formas de pagamento?','PIX, transferência e outros. Entre em contato para combinar.')
) as v(id,q,a)
where not exists (select 1 from public.bp_faqs);

-- ── Corrige o próximo ID gerado após os inserts com id explícito ──
select setval(pg_get_serial_sequence('public.bp_pets','id'), coalesce((select max(id) from public.bp_pets),0)+1, false);
select setval(pg_get_serial_sequence('public.bp_contas','id'), coalesce((select max(id) from public.bp_contas),0)+1, false);
select setval(pg_get_serial_sequence('public.bp_gamepasses','id'), coalesce((select max(id) from public.bp_gamepasses),0)+1, false);
select setval(pg_get_serial_sequence('public.bp_faqs','id'), coalesce((select max(id) from public.bp_faqs),0)+1, false);
