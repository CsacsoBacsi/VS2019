PROCEDURE sp_soap_connection(p_webservice_url  IN  VARCHAR2,
                             p_soap_action     IN  VARCHAR2,
                             p_request_string  IN  CLOB,
                             p_response_xml    OUT XMLTYPE,
                             p_error_message   OUT VARCHAR2)
IS

l_http_data        CLOB;
l_http_data_clob   CLOB;
l_http_request     UTL_HTTP.req;
l_http_response    UTL_HTTP.resp;
l_soap_xml         XMLTYPE         DEFAULT NULL;
l_soap_xml_error   XMLTYPE         DEFAULT NULL;
b_http_data        CLOB;
v_temp1            VARCHAR2(100);
v_temp2            VARCHAR2(100);
BEGIN

   dbms_output.put_line(p_request_string);

   -- Wrap soap envelope around the request
   l_http_data := '<?xml version="1.0" encoding="utf-8"?>' ||
                  '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'||
--                  '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">' ||
--                  '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' ||
                  '<soap:Body>' ||
                  p_request_string ||
                  '</soap:Body>' ||
                  '</soap:Envelope>';
   -- BEGIN the HTTP request function

   l_http_request := UTL_HTTP.begin_request(
      url          => p_webservice_url,
      method       => 'POST'                      ,
      http_version => NULL                        );

   -- Set header data
   UTL_HTTP.set_header(
      r     => l_http_request,
      name  => 'Content-Type',
      value => 'text/xml; charset=utf-8' );

   UTL_HTTP.set_header(
      r     => l_http_request,
      name  => 'Content-Length',
      value => LENGTH(l_http_data)   );

   UTL_HTTP.set_header(
      r     => l_http_request,
      name  => 'SOAPAction',
      value => p_soap_action  );

   UTL_HTTP.write_text(
      r    => l_http_request,
      data => l_http_data  );

   -- Call the ECOES Gateway web service
   l_http_response := UTL_HTTP.get_response(l_http_request);
/*
   for i in 1..Utl_Http.Get_Header_Count ( r => l_http_response )

    loop
      Utl_Http.Get_Header (
      r => l_http_response,
      n => i,
      name => v_temp1,
      value => v_temp2);
      Dbms_Output.Put_Line ( v_temp1 || ': ' || v_temp2);
    end loop;
*/
--   utl_http.get_header(r => l_http_request,name => v_temp1, value => v_temp2);
   --  Read the response into a string, for later conversion to XML

   BEGIN
     LOOP
        utl_http.read_line(r => l_http_response, data => b_http_data);
       /*UTL_HTTP.read_text(
         r    => l_http_response,
         data => l_http_data,
         len  => NULL
       );*/
       IF l_http_data_clob IS NULL THEN
         l_http_data_clob := b_http_data;
       ELSE
         l_http_data_clob := l_http_data_clob || b_http_data;
       END IF;
     END LOOP;
   EXCEPTION
     WHEN UTL_HTTP.END_OF_BODY THEN
       NULL;
   END;

   l_http_data_clob := REPLACE(l_http_data_clob,' xmlns=""','');
   l_http_data_clob := REPLACE(l_http_data_clob,' xmlns="http://powergen.co.uk/icewebservices/"','');
   l_http_data_clob := REPLACE(l_http_data_clob,'GetMPANDetailsResponse','getmpandetailsresponse');
   l_http_data_clob := REPLACE(l_http_data_clob,'GetMPANDetailsResult','getmpandetailsresult');
   l_http_data_clob := REPLACE(l_http_data_clob,'GetAddressDetailsResult','getaddressdetailsresult');
   l_http_data_clob := REPLACE(l_http_data_clob,'GetAddressDetailsResponse','getaddressdetailsresponse');
   l_http_data_clob := REPLACE(l_http_data_clob,'GetMSNDetailsResult','getmsndetailsresult');
   l_http_data_clob := REPLACE(l_http_data_clob,'GetMSNDetailsResponse','getmsndetailsresponse');

   -- END the HTTP request function
   UTL_HTTP.end_response(
      r => l_http_response
      );

   -- Check for client errors
   IF l_http_response.status_code BETWEEN 400 AND 499 THEN
      p_error_message := 'Client error ' ||
                         l_http_response.status_code ||
                         '. check url - ' ||
                         p_webservice_url;
      RETURN;
   END IF;

   -- Check for server errors
   IF l_http_response.status_code BETWEEN 500 AND 599 THEN
      p_error_message := 'Server error ' ||
                         l_http_response.status_code ||
                         '. check url - ' ||
                         p_webservice_url;
      RETURN;
   END IF;

   -- Convert response data to xml
   l_soap_xml := XMLTYPE(l_http_data_clob).EXTRACT('/soap:Envelope/soap:Body/child::node()',
                                               'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');

-- Check for soap exceptions.
   l_soap_xml_error := l_soap_xml.EXTRACT('/soap:Fault/detail/Exception',
                                            'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   IF l_soap_xml_error IS NOT NULL THEN
      IF l_soap_xml_error.EXISTSNODE('Exception/ErrorText') = 1 THEN
         IF l_soap_xml_error.EXTRACT('Exception/ErrorText/text()').getstringval()
         LIKE 'Cannot process request due to the following validation error%' THEN
            p_error_message := l_soap_xml_error.EXTRACT('Exception/ErrorVariables/ErrorVariable[1]/text()').getstringval();
            RETURN;
         ELSE
            p_error_message := l_soap_xml_error.EXTRACT('Exception/ErrorText/text()').getstringval();
            RETURN;
         END IF;  -- IF l_soap_xml_error.EXTRACT('Exception/ErrorText/text()').getstringval()
      END IF;  -- IF l_soap_xml_error.EXISTSNODE('Exception/ErrorText') = 1 THEN
   END IF;  -- IF l_soap_xml_error IS NOT NULL THEN

   -- check for soap faults.
   l_soap_xml_error := l_soap_xml.EXTRACT('/soap:Fault/faultstring',
                                            'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"');
   IF l_soap_xml_error IS NOT NULL THEN
      IF l_soap_xml_error.EXISTSNODE('faultstring') = 1 THEN
         p_error_message := l_soap_xml_error.EXTRACT('faultstring/text()').getstringval();
         RETURN;
      END IF;  -- IF l_soap_xml_error.EXISTSNODE('faultstring') = 1 THEN
   END IF;  -- IF l_soap_xml_error IS NOT NULL THEN

  -- Return the response.
  p_response_xml := l_soap_xml;
/*
EXCEPTION
   WHEN others THEN
      p_error_message := SUBSTR('An unexpected exception occurred: ' ||
                         SQLCODE||' '||SQLERRM, 1, 400);
*/
END sp_soap_connection;
