package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.commons.constants.Constants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * url要和controller方法处理完请求之后，响应信息返回页面的资源目录保持一致
     *
     * /WEB-INF/pages/settings/qx/user/toLogin.do
     * 所有的资源文件都在/WEB-INF/pages目录下，所以可省略
     * 最前面的 / 代表应用的根
     *
     */
    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin(){
        // 请求转发到登录页面 .jsp
        return "settings/qx/user/login";
    }

    // 返回ajax就使用Object，因为返回的数据量可能会变。返回的json封装到java对象中。登录验证
    //响应处理完之后跳到什么页面，和那个页面的资源路径一致，后面名字和方法名一致
    @RequestMapping("/settings/qx/user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpSession session, HttpServletResponse response){
        //封装参数成map，为了方便传给sql使用
        Map<String, Object> map = new HashMap<>();
        //sql根据key取value
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);
        //sql语句不需要这个参数，所以不需要封装isRemPwd

        //调用service方法，查询用户
        User user = userService.queryUserByLoginActAndPwd(map);

        //根据查询结果生成响应信息
        ReturnObject returnObject = new ReturnObject();
        if (user == null) {
            //登录失败，用户名或密码错误
            returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("Login unsuccessful.Username or Password is incorrect.");
        }else { //进一步账号是否合法
            // user.getExpireTime() //2019-01-20 设置表格让user点击
            // new Date() 保持两者格式一致
            String nowStr = DateUtils.formateDateTime(new Date());

            if (nowStr.compareTo(user.getExpireTime()) > 0){ //前面大，过期
                //登录失败，账号已过期
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("Login unsuccessful.Your account has expired.");
            }else if ("0".equals(user.getLockState())){ //判断状态是否被锁定
                //登录失败，状态被锁定
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("Login unsuccessful.Your status is locked.");
            }else if (!user.getAllowIps().contains(request.getRemoteAddr())){ //判断请求的ip地址是否在用户ip地址内
                //登录失败，ip地址受限
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("Login unsuccessful.Restricted IP address.");
            }else {
                //登录成功
                returnObject.setCode(Constants.RETURN_OBJECT_CODE_SUCCESS);
                //把用户保存到session中,页面中从session取出用户名显示
                session.setAttribute(Constants.SESSION_USER, user);

                //10天免登录记住密码，需要往外写cookie
                Cookie c1 = new Cookie("loginAct", user.getLoginAct());
                Cookie c2 = new Cookie("loginPwd", user.getLoginPwd());
                if ("true".equals(isRemPwd)){
                    //10天免登录
                    c1.setMaxAge(60*60*24*10);
                    c2.setMaxAge(60*60*24*10);

                    //往外写cookie
                    //响应cookie给浏览器，浏览器自动保存再硬盘文件中10天
                    response.addCookie(c1);
                    response.addCookie(c2);
                }else {
                    //把没有过期的cookie删除
                    c1.setMaxAge(0);
                    c2.setMaxAge(0);

                    //往外写cookie
                    //响应cookie给浏览器，浏览器自动保存再硬盘文件中10天
                    response.addCookie(c1);
                    response.addCookie(c2);
                }
            }
        }

        return returnObject; //加了@ResponseBody，springmvc自动转成json格式

    }

    //最终要返回的到登录页
    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpServletResponse response, HttpSession session){
        //清空cookie
        Cookie c1 = new Cookie("loginAct", "1");
        Cookie c2 = new Cookie("loginPwd", "1");
        c1.setMaxAge(0);
        c2.setMaxAge(0);
        response.addCookie(c1);
        response.addCookie(c2);

        //销毁session
        session.invalidate();

        //重定向到首页，使用重定向，需要url地址变成登录页面
        //springmvc重定向，屏蔽视图解析器。
        // response.sendRedirect("/crm/")。自动加上项目名
        return "redirect:/";
    }
}
