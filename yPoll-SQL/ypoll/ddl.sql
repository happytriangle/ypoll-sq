drop table ypoll.ID;

create table ypoll.ID
(
	ID bigint 

);

CREATE OR REPLACE FUNCTION ypoll.newid()
  RETURNS bigint AS
$BODY$
DECLARE
	curid bigint;
BEGIN
lock table ypoll.id in ACCESS EXCLUSIVE mode;
  update ypoll.id set id = (select id +1 from ypoll.id);
  select id into curid from ypoll.id;
  return curid;
END; $BODY$
  LANGUAGE plpgsql;
  

create table ypoll.USER( USER_ID bigint not null, FIRST_NAME varchar(255), LAST_NAME varchar(255), primary key(USER_ID));

create table ypoll.USER_SOURCE_MAPPING(USER_ID bigint not null references ypoll.USER(USER_ID),SOURCE_ID varchar(50) not null,SOURCE_ID int not null, 
primary key(USER_ID,SOURCE_ID,SOURCE_TYPE));


CREATE or replace FUNCTION ypoll.ADD_USER(varchar(255) , varchar(255) , varchar(50),int) RETURNS  integer  AS $$
DECLARE
	fName alias for $1;
	lName alias for $2;
	src_id alias for $3;
	src_type alias for $4;
	id integer;
BEGIN
		
	select USER_ID into id from ypoll.USER_SOURCE_MAPPING where SOURCE_ID = src_id and SOURCE_TYPE=src_type;
	if id IS NULL THEN
		select newid() into id;
		insert into ypoll.USER(USER_ID,FIRST_NAME,LAST_NAME) values (id, fName,lName);
		insert into ypoll.USER_SOURCE_MAPPING(USER_ID,SOURCE_ID,SOURCE_TYPE) values(id,src_id,src_type);
	end if;
	return id;
END; $$
LANGUAGE PLPGSQL;

drop table ypoll.QUESTION;
create table ypoll.QUESTION(QUESTION_ID bigint,USER_ID bigint not null references ypoll.USER(USER_ID),QUESTION_TEXT varchar(255), primary key(QUESTION_ID));
drop table ypoll.ANSWER;
create table ypoll.ANSWER(ANSWER_ID bigint, QUESTION_ID bigint references ypoll.QUESTION(QUESTION_ID),USER_ID bigint not null references ypoll.USER(USER_ID),QUESTION_TEXT varchar(255), primary key (ANSWER_ID));

drop table ypoll.VOTE;
create table ypoll.VOTE(QUESTION_ID bigint references ypoll.QUESTION(QUESTION_ID),
ANSWER_ID bigint references ypoll.ANSWER(ANSWER_ID),
USER_ID bigint not null references ypoll.USER(USER_ID), primary key (QUESTION_ID,ANSWER_ID,USER_ID));
