create table if not exists company
(
    id    bigint not null
        primary key,
    name  varchar(60),
    nit   varchar(10),
    state varchar(255)
        constraint company_state_check
            check ((state)::text = ANY
                   ((ARRAY ['ACTIVE'::character varying, 'INACTIVE'::character varying, 'DELETED'::character varying, 'PAUSADO'::character varying])::text[]))
)
;


create table if not exists product
(
    id          bigint      not null
        primary key,
    description varchar(255),
    name        varchar(60) not null,
    price       numeric(20, 10),
    stock       integer,
    company_id  bigint      not null
        constraint fkghawd5rtv8ok565nwpdyyuto9
            references company
);

create index if not exists idx_company_id
    on product (company_id);

create table if not exists my_user
(
    id              bigint      not null
        primary key,
    name            varchar(60) not null,
    lastname        varchar(60) not null,
    document_number varchar(20) not null,
    age             integer,
    gender          varchar(255)
)
;

alter table my_user
    owner to user_01;

create table if not exists _session
(
    id         integer not null
        primary key,
    _timestamp timestamp,
    user_id    integer
        references my_user
)
;


create table if not exists nota_venta
(
    id          bigint not null
        primary key,
    date        timestamp(6),
    customer_id bigint not null
        constraint fk5mg138jjhmcayl37wg2pbblq0
            references my_user,
    total       numeric(20, 10)
);

alter table nota_venta
    owner to user_01;

create table if not exists detalle_nota_venta
(
    id            bigint not null
        primary key,
    price         numeric(20, 10),
    quantity      integer,
    total         numeric(20, 10),
    nota_venta_id bigint not null
        constraint fkgqt9h8h3h5p2t3gh81mgbalqt
            references nota_venta,
    product_id    bigint not null
        constraint fkjpwvkv4e67n9haunh0t70s03
            references product
);

---- SECUENCIAS
create sequence seq_company_id;
create sequence seq_product_id;
create sequence seq_my_user
    maxvalue 1000000000000000;
create sequence seq_session
    maxvalue 1000000000000000;
create sequence seq_det_nota_venta_id;
create sequence seq_nota_venta_id;


--- INSERT


-- Insert aleatorio de varios registros
INSERT INTO my_user (id, name, lastname, document_number, age, gender)
SELECT nextval('seq_my_user'),
       'Nombre' || s.i,
       'Apellido' || s.i,
       SUBSTR(md5(random()::text), 1, 15),
       floor(random() * (65 - 18 + 1) + 18),
       CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END
FROM generate_series(1, 100000) AS s(i);
commit;


INSERT INTO _session (id, _timestamp, user_id)
SELECT nextval('seq_session'),
       now(),
       random(1, 100000)
FROM generate_series(1, 1000000) AS s(i);
commit;

INSERT INTO _session(id, _timestamp)
values (nextval('seq_session'), now()),
       (nextval('seq_session'), now()),
       (nextval('seq_session'), now()),
       (nextval('seq_session'), now()),
       (nextval('seq_session'), now()),
       (nextval('seq_session'), now()),
       (nextval('seq_session'), now())
;

INSERT INTO company (id, name, nit, state)
SELECT nextval('seq_company_id'),
       'Company ' || s.i,
       random(1, 99999),
       'ACTIVE'
FROM generate_series(1, 1000) AS s(i);
commit;



INSERT INTO product (id, name, price, stock, company_id)
SELECT nextval('seq_product_id'),
       'Producto ' || s.i,
       floor(random() * 3),
       random(1, 30),
       random(1, 100)
FROM generate_series(1, 100000) AS s(i);
commit;


INSERT INTO nota_venta (id, total, date, customer_id)
SELECT nextval('seq_nota_venta_id'),
       floor(random() * 3),
       now(),
       random(1, 100)
FROM generate_series(1, 100000) AS s(i);
commit;


INSERT INTO detalle_nota_venta (id, price, quantity, total, nota_venta_id, product_id)
SELECT nextval('seq_det_nota_venta_id'),
       floor(random() * 3),
       random(1, 4),
       floor(random() * 3),
       random(1, 1000),
       random(1, 1000)
FROM generate_series(1, 1000000) AS s(i);
commit;

---------------------------------------------- CONSULTAS -----------------------------------------

-- Consulta con usando producto cartesiano

SELECT u.name cliente, nv.date fecha, nv.total
FROM MY_USER u,
     nota_venta nv
WHERE u.id = nv.customer_id
  AND u.name LIKE 'Nombre%';

SELECT count(*)
FROM MY_USER u,
     nota_venta nv
WHERE u.id = nv.customer_id;

---

SELECT u.name as cliente,
       nv.date   fecha,
       nv.total,
       p.name as producto
FROM MY_USER u,
     nota_venta nv,
     detalle_nota_venta dnv,
     product p
WHERE u.id = nv.customer_id
  AND nv.id = dnv.nota_venta_id
  AND dnv.product_id = p.id
  AND u.name like '%100%';

----- INNER JOIN ---------
SELECT u.name cliente, nv.date fecha, nv.total
FROM MY_USER u,
     nota_venta nv
WHERE u.id = nv.customer_id
  AND u.name LIKE 'Nombre%';

SELECT u.name  cliente,
       nv.date fecha,
       nv.total
FROM my_user u
         INNER JOIN nota_venta nv
                    on u.id = nv.customer_id
         INNER JOIN detalle_nota_venta dnv
                    ON nv.id = dnv.nota_venta_id
WHERE u.name LIKE 'Nombre%';

SELECT u.name as cliente,
       nv.date   fecha,
       nv.total,
       p.name as producto
FROM MY_USER u
         INNER JOIN nota_venta nv
                    ON (u.id = nv.customer_id)
         INNER JOIN detalle_nota_venta dnv
                    ON (nv.id = dnv.nota_venta_id)
         INNER JOIN product p
                    ON (dnv.product_id = p.id)
WHERE u.name like '%100%';

-----------------------------
SELECT u.id, sum(nv.total), count(*)
FROM MY_USER u INNER JOIN nota_venta nv
 ON(u.id=nv.customer_id)
GROUP BY u.id;

SELECT * from nota_venta WHERE customer_id=273;

-------

SELECT u.name as cliente,
       p.name as producto,
       count(*) as cantidad_veces
FROM MY_USER u
         INNER JOIN nota_venta nv
                    ON (u.id = nv.customer_id)
         INNER JOIN detalle_nota_venta dnv
                    ON (nv.id = dnv.nota_venta_id)
         INNER JOIN product p
                    ON (dnv.product_id = p.id)
GROUP BY u.id, p.id
ORDER BY cantidad_veces desc
LIMIT 5;
--Nombre4148,Nombre933,11
--Nombre7167,Nombre343,10
--Nombre1938,Nombre539,10
--Nombre5321,Nombre146,10
--Nombre32,Nombre619,9


SELECT u.name as cliente,
       p.name as producto,
       count(dnv.quantity) as cantidad_producto
FROM MY_USER u
         INNER JOIN nota_venta nv
                    ON (u.id = nv.customer_id)
         INNER JOIN detalle_nota_venta dnv
                    ON (nv.id = dnv.nota_venta_id)
         INNER JOIN product p
                    ON (dnv.product_id = p.id)
GROUP BY u.id, p.id
ORDER BY cantidad_producto desc
LIMIT 5;


