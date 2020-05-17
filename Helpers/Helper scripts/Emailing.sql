DECLARE
pn_user_id VARCHAR2 (10) := NULL ;

  CURSOR c_get_error_details IS
    SELECT DISTINCT DECODE(error_type, 0,'General error occurred',
                                       1, 'Alert owner is not currently active',
                                       2, 'Alert owner id is null',
                                       3, 'Invalid alert rating',
                                       4, 'No KID for role id',
                                       5, 'Failed to get Email address',
                                       6,  'Failed to get next review date',
                                            'Unknown') error_text
      ,    error_details
      FROM rng_alert_error
     WHERE created_date > sysdate - 1 ;

  CURSOR c_get_error_count IS
    SELECT COUNT(*) error_count
      FROM rng_alert_error
     WHERE created_date > sysdate - 1 ;

  lv_email_subject  parameter.parameter_str_value%TYPE;
  lv_email_sender   parameter.parameter_str_value%TYPE;
  lv_email_service  parameter.parameter_str_value%TYPE;
  lv_email_soap     parameter.parameter_str_value%TYPE;
  lv_email_to       parameter.parameter_str_value%TYPE;
  lv_email_cc       parameter.parameter_str_value%TYPE;
  lcb_email_body    CLOB;
  lx_response_xml   XMLTYPE;
  lx_soap_body      XMLTYPE;
  ln_email_audit_id email_audit.email_audit_id%TYPE;
  lv_email_start    parameter.parameter_str_value%TYPE;
  lv_email_end      parameter.parameter_str_value%TYPE;
  lv_error_message  VARCHAR2(32767) := NULL;
  lv_location       VARCHAR2(200) ;

  lkv_spu_name      CONSTANT VARCHAR2(61) := 'sp_process_email';

  lv_error_text      VARCHAR2(5000) ;
  ln_error_count     NUMBER := 0 ;
  ln_max_errors      NUMBER := 20 ;
  lv_error_details   rng_alert_error.error_details%TYPE;
  lv_errors          VARCHAR2(5000) ;
  ln_errors_occurred NUMBER := 0 ;
  lv_specific_error  rng_alert_error.error_details%TYPE;
  ld_sent_to_service email_audit.sent_to_service%TYPE ;

BEGIN

  lv_location := 'get email sender';

  SELECT p.parameter_str_value
    INTO lv_email_sender
    FROM parameter p
   WHERE p.parameter_name = 'EMAIL_ALERT_SENDER';

  lv_location := 'get email subject';

  SELECT p.parameter_str_value
    INTO lv_email_subject
    FROM parameter p
   WHERE p.parameter_name = 'EMAIL_SUBJECT';

  lv_location := 'get email service';

  SELECT p.parameter_str_value
    INTO lv_email_service
    FROM parameter p
   WHERE p.parameter_name = 'EMAIL_SERVICE';

  lv_location := 'get email soap';

  SELECT p.parameter_str_value
    INTO lv_email_soap
    FROM parameter p
   WHERE p.parameter_name = 'EMAIL_SOAP';

  lv_location := 'get email start';

  SELECT p.parameter_str_value
    INTO lv_email_start
    FROM parameter p
   WHERE p.parameter_name = 'EMAIL_MAIL_NODE_START';

  lv_location := 'get email end';

  SELECT p.parameter_str_value
    INTO lv_email_end
    FROM parameter p
   WHERE p.parameter_name = 'EMAIL_MAIL_NODE_END';

  lv_location := 'if the user id is not null';

  IF pn_user_id IS NOT NULL THEN

    lv_location := 'get email address';

    lv_email_to := NVL(pkg_rng_alerts.fn_get_email_address(piv_kid => 'A18846'),'Unknown');

    lv_location := 'get email body';

    SELECT alt.alert_message||chr(10)
      INTO lcb_email_body
      FROM alert_timing alt
     WHERE alt.alert_timing_id = 999;

  ELSE

    IF 999 = 999 THEN-- Report on errors

      lv_location := 'get email body (error reporting)';

      SELECT parameter_str_value
        INTO lv_email_to
        FROM parameter
       WHERE parameter_name = 'R_AND_G_REP' ;

      BEGIN

        lv_location := 'get the error count';

        OPEN c_get_error_count ;
        FETCH c_get_error_count INTO ln_errors_occurred ;
        CLOSE c_get_error_count ;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          ln_errors_occurred := 0 ;

      END;

      lv_location := 'if this is an error';

      IF ln_errors_occurred > 0 THEN

        lv_location := 'errors have occurred, get the email body';

        SELECT alt.alert_message||chr(10)
        INTO lcb_email_body
        FROM alert_timing alt
        WHERE alt.alert_timing_id = 999;

        lv_location := 'get the error totals';

        FOR err IN (SELECT COUNT(rng_item_id) error_count,
                         DECODE(error_type, 0,'General error occurred',
                                       1, 'Alert owner is not currently active',
                                       2, 'Alert owner id is null',
                                       3, 'Invalid alert rating',
                                       4, 'No KID for role id',
                                       5, 'Failed to get Email address',
                                       6,  'Failed to get next review date',
                                            'Unknown') error_text
                  FROM rng_alert_error
                 WHERE created_date > sysdate - 1
                 GROUP BY error_type)
        LOOP

          lv_error_text := lv_error_text||err.error_text||' : '||err.error_count||CHR(10)||CHR(10);

        END LOOP ;

        lv_location := 'get the error details';

        OPEN c_get_error_details ;
        LOOP

          FETCH c_get_error_details INTO lv_error_details
                                    ,    lv_specific_error;

          lv_errors:= lv_errors||lv_specific_error||' : '||CHR(10)||lv_error_details||CHR(10);

          ln_error_count := ln_error_count + 1;

          EXIT WHEN c_get_error_details%NOTFOUND;

          IF ln_error_count = ln_max_errors THEN

            lv_errors := lv_errors||lv_specific_error||' : '||lv_error_details||CHR(10)||CHR(10)||'More errors exist'||'('||ln_errors_occurred||')'||CHR(10)||CHR(10);
            EXIT;

          END IF;

        END LOOP;

        lcb_email_body := lcb_email_body||CHR(10)||lv_error_text||CHR(10)||lv_errors||CHR(10);

      END IF;

    END IF ;

  END IF ;

  lv_location := 'build up the email body';

  FOR i IN (SELECT p.parameter_str_value wordings
              FROM parameter p
             WHERE p.parameter_name LIKE 'EMAIL_BODY_%')
  LOOP

     lcb_email_body := lcb_email_body||i.wordings||CHR(10)||CHR(10);

  END LOOP;

  lv_location := 'get the soap body';

  lx_soap_body := XMLTYPE(lv_email_start||chr(10)||
                   '<mail:Attachments/>'||chr(10)||
                   '<mail:Body><![CDATA['||lcb_email_body||']]></mail:Body>'||chr(10)||
                   '<mail:From><![CDATA['||lv_email_sender||']]></mail:From>'||chr(10)||
                   '<mail:IsBodyHtml>false</mail:IsBodyHtml>'||chr(10)||
                   '<mail:Subject><![CDATA['||lv_email_subject||']]></mail:Subject>'||chr(10)||
                   '<mail:To><arr:string><![CDATA['||lv_email_to||']]></arr:string></mail:To>'||chr(10)||
                   lv_email_end);
  lv_location := 'get the email audit unique id';

  dbms_output.put_line (lx_soap_body.getclobval ()) ;
  dbms_output.put_line (lv_error_text) ;

EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE ;

END ;
