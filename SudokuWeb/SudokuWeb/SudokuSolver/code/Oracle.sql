drop table sudoku_user ;
create table sudoku_user (
  user_id number,
  user_name varchar2 (100)
)
;

alter table SUDOKU_USER
  add constraint SUDOKU_USER_PK primary key (USER_ID)
  using index 
;

alter table SUDOKU_USER
  add CONSTRAINT SUDOKU_USER_UK UNIQUE (USER_NAME)
  USING INDEX 
;

drop table sudoku_grid_header ;
create table sudoku_grid_header
(user_id number,
 grid_title varchar2 (100),
 created_datetime TIMESTAMP,
 time_taken number,
 grid_comment varchar2 (200),
 grid_id number
)
;

alter table SUDOKU_GRID_HEADER
  add constraint SUDOKU_GRID_HEADER_FK foreign key (USER_ID)
  references SUDOKU_USER (USER_ID) on delete cascade
;

drop table sudoku_grid_detail ;
create table sudoku_grid_detail
(grid_id number,
 cell_id number (2),
 cell_val number (1)
)
;

alter table SUDOKU_GRID_HEADER
  add constraint SUDOKU_GRID_HEADER_PK primary key (GRID_ID)
  using index 
;

alter table SUDOKU_GRID_DETAIL
  add constraint SUDOKU_GRID_DETAIL_FK foreign key (GRID_ID)
  references SUDOKU_GRID_HEADER (GRID_ID) on delete cascade
;

create sequence USER_ID_SEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOCYCLE
CACHE 5
;

CREATE SEQUENCE grid_id_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOCYCLE
CACHE 5
;

create or replace package pck_sudoku_solver is
  procedure insertHeader (p_user_name in varchar2, p_grid_title in varchar2, p_created_datetime in varchar2, p_time_taken in number, p_grid_comment in varchar2, sqlrowcnt out number, retval out number) ;
  procedure insertGrid (p_cell_id in number, p_cell_value in number, sqlrowcnt out number, retval out number) ;
  procedure deleteHeader (p_grid_id in number, sqlrowcnt out number, retval out number) ;
  procedure getGridList (p_user_name varchar2, csr_out out sys_refcursor, retval out number) ;
  procedure getGridHeader (p_grid_id number, csr_out out sys_refcursor, retval out number) ;
  procedure getGridCells (p_grid_id number, csr_out out sys_refcursor, retval out number) ;
  function  getGridCount return number ;
  procedure insertUser (p_user_name in varchar2, sqlrowcnt out number, retval out number) ;
  procedure deleteUser (p_user_name in varchar2, sqlrowcnt out number, retval out number) ;
  procedure getUserList (csr_out out sys_refcursor, retval out number) ;
  procedure getUserName (p_user_id in number, out_user_name out varchar2, retval out number) ;
end pck_sudoku_solver
;

create or replace package body pck_sudoku_solver is
-- -------------------------------------------------------------------------------------------------------------------------------
  procedure insertHeader ( -- Insert a single grid into the header table
    p_user_name in varchar2,
    p_grid_title in varchar2,
    p_created_datetime in varchar2,
    p_time_taken in number,
    p_grid_comment in varchar2,
    sqlrowcnt out number,
    retval out number) is

    user_id PLS_INTEGER ;

  begin

    select user_id into user_id
    from   SUDOKU_USER
    where  user_name = p_user_name
    ;
    
    if user_id is null
    then
        retval := -1 ;
        return ;
    end if ;

    insert into SUDOKU_GRID_HEADER (user_id, grid_title, created_datetime, time_taken, grid_comment, grid_id)
           values (user_id, p_grid_title, to_date (p_created_datetime, 'YYYY-MM-DD HH24:MI:SS'), p_time_taken, p_grid_comment, grid_id_seq.nextval)
    ;

    sqlrowcnt := SQL%ROWCOUNT ;
    commit ;
    retval := 0 ;

    exception when others then
      retval := sqlcode ;
      sqlrowcnt := -1 ;
      rollback ;

  end ;
-- -------------------------------------------------------------------------------------------------------------------------------
  procedure insertGrid ( -- Insert a single grid into the detail table
    p_cell_id in number,
    p_cell_value in number,
    sqlrowcnt out number,
    retval out number) is

  begin

    insert into SUDOKU_GRID_DETAIL (grid_id, cell_id, cell_val)
           values (grid_id_seq.currval, p_cell_id, p_cell_value)
    ;

    sqlrowcnt := SQL%ROWCOUNT ;
    commit ;
    retval := 0 ;

    exception when others then
      retval := sqlcode ;
      sqlrowcnt := -1 ;
      rollback ;

  end ;
-- -------------------------------------------------------------------------------------------------------------------------------
  procedure deleteHeader ( -- Delete a single grid from the header table and cascading to detail
    p_grid_id in number,
    sqlrowcnt out number,
    retval out number) is

  begin

    delete from SUDOKU_GRID_HEADER
           where grid_id = p_grid_id
    ;

    sqlrowcnt := SQL%ROWCOUNT ;
    commit ;
    retval := 0 ;

    exception when others then
      retval := sqlcode ;
      sqlrowcnt := -1 ;
      rollback ;

  end ;
-- -------------------------------------------------------------------------
  function getGridCount -- Get the number of grids saved
    return number is
    l_result number ;

  begin

    select count (*) into l_result
    from   SUDOKU_GRID_HEADER
    ;

    return l_result ;

    exception when others then
      return -1 ;

  end ;

-- -------------------------------------------------------------------------
  procedure getGridList ( -- Fetch the user's previously saved grid list
    p_user_name in varchar2,
    csr_out out sys_refcursor,
    retval out number) is

  l_user_id number ;

  begin
  
    select user_id into l_user_id
    from   SUDOKU_USER
    where  user_name = p_user_name
    ;
    
    if l_user_id is null
    then
        retval := -1 ;
        return ;
    end if ;

    open csr_out for 
         select grid_id, grid_title 
         from   SUDOKU_GRID_HEADER
         where  user_id = l_user_id
         order by grid_title ;

    retval := 0 ;

    exception when others then
      retval := sqlcode ;

  end ;

-- -------------------------------------------------------------------------
  procedure getGridHeader (p_grid_id in number, csr_out out sys_refcursor, retval out number) is
  begin

    open csr_out for 
         select grid_id, grid_title, created_datetime, time_taken, grid_comment 
         from   SUDOKU_GRID_HEADER 
         where  grid_id = p_grid_id ;

    retval := 0 ;

    exception when others then
      retval := sqlcode ;
  end ;

-- -------------------------------------------------------------------------
  procedure getGridCells (p_grid_id in number, csr_out out sys_refcursor, retval out number) is
  begin

    open csr_out for 
         select grid_id, cell_id, cell_val 
         from   SUDOKU_GRID_DETAIL 
         where  grid_id = p_grid_id ;

    retval := 0 ;

    exception when others then
      retval := sqlcode ;

  end ;

-- -------------------------------------------------------------------------------------------------------------------------------
  procedure insertUser ( -- Insert a single user into the detail table
    p_user_name in varchar2,
    sqlrowcnt out number,
    retval out number) is

  user_exists PLS_INTEGER ;

  begin

    select count (*) into user_exists 
    from   SUDOKU_USER
    where  user_name = p_user_name
    ;
    
    if user_exists = 0
    then
    
      insert into SUDOKU_USER (user_id, user_name)
             values (user_id_seq.nextval, p_user_name)
      ;

      sqlrowcnt := SQL%ROWCOUNT ;
      commit ;
      retval := 0 ;
      
    else
    
        sqlrowcnt := -1 ;
        retval := -1 ;
        
    end if ;

    exception when others then
      retval := sqlcode ;
      sqlrowcnt := -1 ;
      rollback ;

  end ;

-- -------------------------------------------------------------------------------------------------------------------------------
  procedure deleteUser ( -- Delete a single user from the user table and cascading to grid header
    p_user_name in varchar2,
    sqlrowcnt out number,
    retval out number) is

  begin

    delete from SUDOKU_USER
           where user_name = p_user_name
    ;

    sqlrowcnt := SQL%ROWCOUNT ;
    commit ;
    retval := 0 ;

    exception when others then
      retval := sqlcode ;
      sqlrowcnt := -1 ;
      rollback ;

  end ;

-- -------------------------------------------------------------------------
  procedure getUserList (csr_out out sys_refcursor, retval out number) is

  begin

    open csr_out for 
         select user_id, user_name 
         from   SUDOKU_USER 
         order by user_name ;
    
    retval := 0 ;

    exception when others then
      retval := sqlcode ;

  end ;

-- -------------------------------------------------------------------------
  procedure getUserName (
    p_user_id in number, 
    out_user_name out varchar2, 
    retval out number) is

  begin

    select user_name into out_user_name
    from   SUDOKU_USER
    where  user_id = p_user_id
    ;
    
    retval := 0 ;

    exception when others then
      retval := sqlcode ;

  end ;

end pck_sudoku_solver
;
