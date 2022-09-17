<%--
  Created by IntelliJ IDEA.
  User: 石决明
  Date: 2022/9/11
  Time: 16:59
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <%--引入jquery--%>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <%--引入bs框架--%>
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <%--引入bootstrap-datetimepicker插件--%>
    <link rel="stylesheet" type="text/css" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <%--语言包--%>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js/"></script>
    <title>Title</title>
    <script type="text/javascript">
        $(function(){
            //当容器加载完成，对容器调用工具函数
            $("#myDate").datetimepicker({ //通过参数，显示效果
                language:'en',
                format:'yyyy-mm-dd',
                minView:'month', //最小视图
                initialDate: new Date(), //初始化显示的日期
                autoclose:true, //选择完日期之后，是否自动关闭。默认false
                todayBtn:true, //是否显示今天按钮。默认false
                clearBtn:true //是否清空。默认false

            });
        });
    </script>
</head>
<body>
<%--
readonly: 只读不改可以提交数据
disabled: 只读不改也不可以提交数据
--%>
<input type="text" id="myDate" readonly>

</body>
</html>
