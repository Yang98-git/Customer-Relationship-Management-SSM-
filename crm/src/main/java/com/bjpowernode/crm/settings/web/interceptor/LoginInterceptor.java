package com.bjpowernode.crm.settings.web.interceptor;

import com.bjpowernode.crm.commons.constants.Constants;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        //判断用户是否登录，session中是否有数据
        HttpSession session = request.getSession();
        if (session.getAttribute(Constants.SESSION_USER) == null){
            //没有登录，则手动重定向到登录页面，手动重定向需要加项目名
            // request.getContextPath(): /+项目名
            response.sendRedirect(request.getContextPath()); //项目名+“/”根路径
            return false;
        }
        //已登录
        return true;
    }


}
