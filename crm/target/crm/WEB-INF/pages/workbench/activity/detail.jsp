<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath=request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
%>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;

	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});

		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});

		//新追加的remark是动态元素，使用on()，需要找到父元素，父元素必须是固有元素
		/*$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});*/
		$("#remarkDivList").on("mouseover", ".remarkDiv", function () {
			//this 是正在发生事件的div的DOM对象 (.remarkDiv)
			$(this).children("div").children("div").show();
		});

		/*$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});*/
		$("#remarkDivList").on("mouseout", ".remarkDiv", function () {
			//this 是正在发生事件的div (.remarkDiv)
			$(this).children("div").children("div").hide();
		});

		/*$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});*/
		$("#remarkDivList").on("mouseover", ".myHref", function () {
			//this 是正在发生事件的div (.remarkDiv)
			$(this).children("span").css("color","red");
		});

		/*$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});*/
		$("#remarkDivList").on("mouseout", ".myHref", function () {
			//this 是正在发生事件的div (.remarkDiv)
			$(this).children("span").css("color","#E6E6E6");
		});


		//给保存按钮添加单击事件
		$("#saveCreateActivityRemarkBtn").click(function () {
			//收集参数
			var noteContent = $.trim($("#remark").val());
			//需要加''，先取数据(在后台执行tomcat)，再定义js变量(在浏览器执行)
			//取出的字符串需要加''，不然会被浏览器认为是变量
			var activityId = '${activity.id}';
			//表单验证
			if (noteContent==""){
				alert("The remark can not be empty!");
				return;
			}
			//发送ajax请求
			$.ajax({
				url:'workbench/activity/saveCreateActivityRemark.do',
				data:{
					noteContent:noteContent,
					activityId:activityId
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if (data.code == "1"){
						//清空输入框
						$("#remark").val("");
						//刷新备注列表,只拼一条备注div
						var htmlstr = "";
						htmlstr+="<div id='div_"+data.retData.id+"' class=\"remarkDiv\" style=\"height: 60px;\">";
						//备注创建者不能从retureObject取，因为存的是id不是名字
						//从session中取，备注创建者就是当前用户
						htmlstr+="<img title=\"${sessionScope.sessionUser.name}\" src=\"image/user-thumbnail.png\" style=\"width: 30px; height:30px;\">";
						htmlstr+="<div style=\"position: relative; top: -40px; left: 40px;\" >";
						//可以直接使用局部变量noteContent
						htmlstr+="<h5>"+data.retData.noteContent+"</h5>";
						htmlstr+="<font color=\"gray\">Marketing Activity</font> <font color=\"gray\">-</font> <b>${activity.name}</b> <small style=\"color: gray;\"> "+data.retData.createTime+" by ${sessionScope.sessionUser.name} created</small>";
						htmlstr+="<div style=\"position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;\">";
						htmlstr+="<a name='editA' remarkId=\""+data.retData.id+"\" class=\"myHref\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-edit\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlstr+="&nbsp;&nbsp;&nbsp;&nbsp;";
						htmlstr+="<a name='deleteA' remarkId=\""+data.retData.id+"\" class=\"myHref\" href=\"javascript:void(0);\"><span class=\"glyphicon glyphicon-remove\" style=\"font-size: 20px; color: #E6E6E6;\"></span></a>";
						htmlstr+="</div>";
						htmlstr+="</div>";
						htmlstr+="</div>";

						//追加显示，after不好找，还没遍历出来,append显示在内部的后面，包括的输入框
						//找输入框的before
						$("#remarkDiv").before(htmlstr);

					}else {
						alert(data.message);
					}
				}
			});

		});

		//给所有删除图标添加单击事件，有可能有新添加的动态备注，需要on(),找固有父元素
		//子元素不能用id定位，id不可重复，使用name标签
		$("#remarkDivList").on("click", "a[name='deleteA']", function () {
			//收集参数
			//自定义的属性只能用 jq对象.attr("attrName")
			//this 是正在发生事件的 a[name='deleteA'] 的DOM对象
			var id = $(this).attr("remarkId");
			$.ajax({
				url:'workbench/activity/deleteActivityRemarkById.do',
				data: {
					id:id
				},
				type: 'post',
				dataType: 'json',
				success:function (data) {
					if (data.code=='1'){
						//刷新备注列表，其他的不动
						//每条备注div添加id属性，id是自己的remarkid
						$("#div_"+id).remove();
					}else {
						alert(data.message);
					}
				}
			});
		});

		//给市场活动备注后面修改图标添加单击事件,动态元素，on()找固有父元素
		$("#remarkDivList").on("click", "a[name='editA']", function () {
			//收集参数
			var id = $(this).attr("remarkId");
			//父子选择器, 空格，父子选择器
			var nodeContent = $("#div_"+id+" h5").text();
			//显示到修改备注模态窗口
			$("#edit-id").val(id); //给id隐藏域赋值
			$("#edit-noteContent").val(nodeContent);
			//弹出修改市场活动备注模态窗口
			$("#editRemarkModal").modal("show");
		});

		//给市场活动备注更模态窗口更新按钮添加单击事件
		$("#updateRemarkBtn").click(function () {
			//收集参数
			var id = $("#edit-id").val();
			var noteContent = $.trim($("#edit-noteContent").val());
			//表单验证
			if (noteContent==""){
				alert("The remark can not be empty!");
				return;
			}
			//发送请求
			$.ajax({
				url:'workbench/activity/saveEditActivityRemark.do',
				data: {
					id:id,
					noteContent:noteContent
				},
				type: 'post',
				dataType: 'json',
				success:function (data) {
					if (data.code=='1'){
						//关闭模态窗口
						$("#editRemarkModal").modal("hide");

						//刷新备注列表,只拼一条备注div,覆盖显示,父子选择器
						$("#div_"+data.retData.id+" h5").text(data.retData.noteContent);
						//当前用户修改的
						$("#div_"+data.retData.id+" small").text(" "+data.retData.editTime+" by ${sessionScope.sessionUser.name} edited");

					}else {
						alert(data.message);
						//模态窗口不关闭
						$("#editRemarkModal").modal("show");
					}
				}
			});

		});


	});

</script>

</head>
<body>

	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">Modify the Remark</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
						<%--remark隐藏域id--%>
						<input type="hidden" id="edit-id">
                        <div class="form-group">
                            <label for="edit-noteContent" class="col-sm-2 control-label">Content</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close </button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">Update </button>
                </div>
            </div>
        </div>
    </div>



	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>

	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>Marketing Activity-${activity.name} <small>${activity.startDate} ~ ${activity.endDate}</small></h3>
		</div>

	</div>

	<br/>
	<br/>
	<br/>

	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">Owner</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">Name</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">Start Date</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">End Date</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activity.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">Cost</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">Create By</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">Edit By</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">Description</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>

	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;" id="remarkDivList">
		<div class="page-header">
			<h4>Remark</h4>
		</div>

		<%--遍历remarkList，显示所有的备注--%>
		<c:forEach items="${remarkList}" var="remark">
			<div id="div_${remark.id}" class="remarkDiv" style="height: 60px;">
				<img title="${remark.createBy}" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
				<div style="position: relative; top: -40px; left: 40px;" >
					<h5>${remark.noteContent}</h5>
					<font color="gray">Marketing Activity</font> <font color="gray">-</font> <b>${activity.name}</b> <small style="color: gray;"> ${remark.editFlag=='1'?remark.editTime:remark.createTime} by ${remark.editFlag=='1'?remark.editBy:remark.createBy}${remark.editFlag=='1'?' edited':' created'}</small>
					<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
						<a name='editA' remarkId="${remark.id}" class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
						&nbsp;&nbsp;&nbsp;&nbsp;
						<a name='deleteA' remarkId="${remark.id}" class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
					</div>
				</div>
			</div>
		</c:forEach>
		<!-- 备注1 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>

		<!-- 备注2 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>

		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="add a remark..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 725px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">Cancel</button>
					<button type="button" class="btn btn-primary" id="saveCreateActivityRemarkBtn">Save</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>
