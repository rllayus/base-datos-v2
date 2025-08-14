drop table if exists my_user;
drop sequence if exists seq_my_user;


create table my_user
(
    id              int primary key,
    name            varchar(60) not null,
    lastname        varchar(60) not null,
    document_number varchar(15) not null,
    age             int,
    gender          char(1)
);

create table _session
(
    id         int primary key,
    _timestamp timestamp,
    user_id    int,
    foreign key (user_id) references my_user (id)
);


CREATE SEQUENCE seq_my_user
    INCREMENT BY 1
    START WITH 1
    MAXVALUE 1000000000000000;

CREATE SEQUENCE seq_session
    INCREMENT BY 1
    START WITH 1
    MAXVALUE 1000000000000000;

-- Definir un generador de valores por defecto para una columna
--ALTER TABLE my_user ALTER COLUMN id SET DEFAULT nextval('seq_my_user');



--- Insert de varios registros
insert into my_user(id, name, lastname, document_number, age, gender)
values (nextval('seq_my_user'), 'Ricardo', 'Laredo', '11231231231', 18, 'F'),
       (nextval('seq_my_user'), 'Ricardo', 'Laredo', '11231231231', 20, 'M');


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
FROM generate_series(1, 100000) AS s(i);
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

------
INSERT INTO company (id, name, nit, state)
SELECT nextval('seq_company_id'),
       'Company ' || s.i,
       random(1, 99999),
       'ACTIVE'
FROM generate_series(1, 100) AS s(i);
commit;



INSERT INTO product (id, name, price, stock, company_id)
SELECT nextval('seq_product_id'),
       'Producto ' || s.i,
       floor(random() *  3),
       random(1, 30),
       random(1, 100)
FROM generate_series(1, 100000) AS s(i);
commit;


INSERT INTO nota_venta (id, total, date, customer_id)
SELECT nextval('seq_nota_venta_id'),
       floor(random() *  3),
       now(),
       random(1, 10000)
FROM generate_series(1, 100000) AS s(i);
commit;


INSERT INTO detalle_nota_venta (id, price, quantity, total, nota_venta_id, product_id)
SELECT nextval('seq_det_nota_venta_id'),
       floor(random() *  3),
       random(1, 4),
       floor(random() *  3),
random(1, 100000),
random(1, 100000)
FROM generate_series(1, 2000000) AS s(i);
commit;




