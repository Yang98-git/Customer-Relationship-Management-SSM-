<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
<base href="<%=basePath%>">
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<title>Title</title>
<script type="text/javascript">
    $(function () {
        //给下载按钮添加单击事件
        $("#fileDownloadBtn").click(function () {
            //文件下载必须是同步请求
            window.location.href="workbench/activity/fileDownload.do";
        });
    });
</script>


</head>
<body>
<input type="button" value="Download" id="fileDownloadBtn">
</body>
</html>
