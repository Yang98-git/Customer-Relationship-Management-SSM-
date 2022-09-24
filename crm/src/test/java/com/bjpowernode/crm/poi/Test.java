package com.bjpowernode.crm.poi;

public class Test {
    @org.junit.Test
    public void test(){
        char initial = 'A';
        int [] stNo = new int [5];
        String [] stName = new String [5];
        for (int i = 0; i < stNo.length; i++) {
            stNo[i] = i;
            stName [i] = new String(Character.toString((char) (i + initial) ));
            System.out.println("stNo:" + stNo[i]);
            System.out.println("stName:" + stName[i]);
        }

    }
}
