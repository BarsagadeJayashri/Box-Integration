public class Box_Authorize {
    
    public String clientId		{get;set;}
    public String clientSecret 	{get;set;}
    public String callback 		{get;set;}
    public String state	 		{get;set;}
    public String scope	 		{get;set;}
    public String code	 		{get;set;}
    public String accessToken	{get;set;}
    public String result2		{get;set;}
    
    public Box_Authorize() {
        callback = 'https://empathetic-impala-4f0p2h-dev-ed--c.trailblaze.vf.force.com/apex/BoxResponse';
    }
    
    /*Request code 
*Endpoint : https://account.box.com/api/oauth2/authorize?
*Method : GET
*client_id : ClientId in connected app
*response_type =code
*redirect_uri = callback url registered in connected app.
*state=anyrandom string
*/
    public PageReference requestCode() {
        String url = 'https://account.box.com/api/oauth2/authorize?';
        url = url + 'response_type=code';
        url = url+ '&client_id='+clientId;
        url = url + '&redirect_uri='+callback;
        PageReference p = new PageReference(url);
        return p;
    }
    
    public void readCode() {
        code = Apexpages.currentPage().getParameters().get('code');
    }
    
    /*Request Access Token 
*Endpoint : 
*Method : POST
*grant_type =  authorization_code
*code  =code received in the above step
*client_id = Client Id fom connected app
*client_secret = Client Secret fom connected app
*redirect_uri = callback url
*/
    public void requestToken(){
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        
        String url = 'https://api.box.com/oauth2/token';
        request.setEndPoint(url);
        
        String body = 'client_id=' + ClientId;
        body = body + '&client_secret='+ClientSecret;
        body = body + '&code='+code;
        body = body + '&grant_type=authorization_code';
        
        request.setMethod('POST');
        request.setBody(body);
        
        HttpResponse response = h.send(request);
        
        String result = response.getBody();
        
        System.JSONParser jp = JSON.createParser(result);
        
        while(jp.nextToken() != null) {
            if(jp.getText() == 'access_token') {
                jp.nextToken();
               	accessToken = jp.getText();
            }
        }
    }
    
    public void createNewFolder() {
        String url = 'https://api.box.com/2.0/folders';
        String body = '{"name":"NewFolder1","parent":{"id":"0"}}';
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer '+ accessToken);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(body);
        
        HttpResponse response = h.send(req);
        String result1 = response.getBody();
        System.debug(result1);
    }
    public void getListItemInFolder() {
        String url = 'https://api.box.com/2.0/folders/0/items';
        
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer '+ accessToken);
        
        
        HttpResponse response = h.send(req);
        result2 = response.getBody();
        System.debug(result2);
    }
}