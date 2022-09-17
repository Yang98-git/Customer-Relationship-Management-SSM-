<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
<base href="<%=basePath%>">
<%--jQuery--%>
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<%--Bootstrap--%>
<link rel="stylesheet" type="text/css" href="jquery/bootstrap_3.3.0/css/bootstrap.min.css">
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<%--Pagination plugin--%>
<link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
<title>Title</title>

<script type="text/javascript">
    $(function () {
        $("#demo_pag1").bs_pagination({
            currentPage: 1, //当前页号，pageNo，用户输入

            rowsPerPage: 10, //pageSize，用户输入
            totalRows: 1000, //总条数，默认1000，数据库查出来
            totalPages: 100, //总页数，必填

            visiblePageLinks: 5, //一组显示几页，默认5

            showGoToPage: true, //是否显示跳转到具体页面，默认T
            showRowsPerPage: true, //是否显示“每页显示条数”
            showRowsInfo: true, //是否显示记录信息

            //pageObj: 翻页对象，有以上{}中所有参数
            onChangePage: function (event, pageObj){ //切换页号，执行js
                //return pageNo and pageSize after a link has clicked
                alert(pageObj.currentPage);
                alert(pageObj.rowsPerPage);
            }
        });
    });
</script>

</head>
<body>
<div id="demo_pag1"></div>
</body>
</html>
