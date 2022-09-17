<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<%
	String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<%--给整个网页配置基础路径--%>
<%--<base href="http://127.0.0.1:8080/crm/">--%>
<base href="<%=basePath%>">
<head>
<meta charset="UTF-8">
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript">

	$(function () {
		//给浏览器窗口添加keydown
		$(window).keydown(function (e){ //e是事件本身
			//判断是不是回车键，是则提交登录请求
			if (e.keyCode==13){
				//模拟登录按钮单击事件
				$("#loginBtn").click();
			}

		});

		//给登录按钮添加单击事件
		$("#loginBtn").click(function () {
			//收集参数
			var loginAct = $.trim($("#loginAct").val());
			var loginPwd = $.trim($("#loginPwd").val());
			var isRemPwd = $("#isRemPwd").prop("checked");

			if (loginAct==""){
				alert("Username can not be empty！")
				return;
			}
			if (loginPwd==""){
				alert("Password can not be empty！")
				return;
			}

			//显示正在验证
			//$("#msg").text("Verifying the account....");

			//发送异步请求
			$.ajax({
				url:'settings/qx/user/login.do', //本页所有url从base往下找，不需要/
				data:{ //json名要和后台controller形参名保持一致
					loginAct:loginAct,
					loginPwd:loginPwd,
					isRemPwd:isRemPwd
				},
				type:'post',
				dataType:'json', //响应信息的类型
				success:function (data) { //处理响应，data接收后台响应的信息,returnObject
					if (data.code === "1"){
						//js跳转到业务主页面，在WEB-INF不能直接跳转，需要跳转control
						//window.location.href重新在地址栏发请求找controller跳转
						window.location.href="workbench/index.do";
					}else {
						//提示信息
						$("#msg").html(data.message);
					}
				},
				beforeSend:function () { //ajax向后台发请求之前，执行此函数。该函数的返回值，可觉得ajax是否真正发请求。如果该函数返回true，则ajax会真正向后台发请求
					/*//表单验证
					if (loginAct==""){
						alert("Username can not be empty！")
						return false;
					}
					if (loginPwd==""){
						alert("Password can not be empty！")
						return false;
					}
					return true;*/
					$("#msg").text("Verifying the account....");
					return true;
				}
			})
		})
	});
</script>

</head>

<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2022&nbsp;Yang Xu</span></div>
	</div>

	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>Login</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" id="loginAct" type="text" value="${cookie.loginAct.value}" placeholder="username">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" id="loginPwd" type="password" value="${cookie.loginPwd.value}" placeholder="password">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd" checked>
							</c:if>
							<c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd">
							</c:if>
							Remember me for 10 days
						</label>
						&nbsp;&nbsp;<br>
						<span id="msg" style="color: red"></span>
					</div>
					<%--submit是同步提交--%>
					<button type="button" id="loginBtn" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">Login</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>
