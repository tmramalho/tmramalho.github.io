---
id: 73
title: SASS is awesome and you should use it
date: 2013-02-02T14:13:28+00:00
author: Tiago Ramalho
layout: post
guid: http://nehalemlabs.net/prototype/?p=73
permalink: /blog/2013/02/02/sass-is-awesome-and-you-should-use-it/
categories:
  - Development
tags:
  - code
  - design
  - web
---
Trying to fix some bugs in the mobile layout for <a href="http://www.prospicious.com/" target="_blank">prospicious</a> I realized the stylesheets had become an unmaintainable mess.
So I converted the codebase to use <a href="http://sass-lang.com/" target="_blank">SASS</a> which was a bit of a pain because I had to convert well over 800 lines by hand.
Luckily though there is backward compatibility so I could leave many classes untouched.
However monstrosities like

```sass
#facebookLogin {
        border: 1px solid #5870ac;
        text-shadow: 1px -1px 1px #5870AC;
        background: #607cb3;
        background: -moz-linear-gradient(top,  #607cb3 0%, #3c62a1 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#607cb3), color-stop(100%,#3c62a1));
        background: -webkit-linear-gradient(top,  #607cb3 0%,#3c62a1 100%);
        background: -o-linear-gradient(top,  #607cb3 0%,#3c62a1 100%);
        background: -ms-linear-gradient(top,  #607cb3 0%,#3c62a1 100%);
        background: linear-gradient(top,  #607cb3 0%,#3c62a1 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#607cb3', endColorstr='#3c62a1',GradientType=0 );

}

#facebookLogin:hover {
        background: #6e8ac1;
        background: -moz-linear-gradient(top,  #6e8ac1 0%, #426aab 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#6e8ac1), color-stop(100%,#426aab));
        background: -webkit-linear-gradient(top,  #6e8ac1 0%,#426aab 100%);
        background: -o-linear-gradient(top,  #6e8ac1 0%,#426aab 100%);
        background: -ms-linear-gradient(top,  #6e8ac1 0%,#426aab 100%);
        background: linear-gradient(top,  #6e8ac1 0%,#426aab 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#6e8ac1', endColorstr='#426aab',GradientType=0 );
}

#facebookLogin:active {
        background: #375e9e;
        background: -moz-linear-gradient(top,  #375e9e 0%, #5b78b0 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#375e9e), color-stop(100%,#5b78b0));
        background: -webkit-linear-gradient(top,  #375e9e 0%,#5b78b0 100%);
        background: -o-linear-gradient(top,  #375e9e 0%,#5b78b0 100%);
        background: -ms-linear-gradient(top,  #375e9e 0%,#5b78b0 100%);
        background: linear-gradient(top,  #375e9e 0%,#5b78b0 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#375e9e', endColorstr='#5b78b0',GradientType=0 );
}
```

can be simplified by the use of <a href="http://sass-lang.com/tutorial.html" target="_blank">mixins</a>, essentially the SASS version of macros:

```sass
@mixin socialLoginBackground(<span>$col1,$</span>col2) {
        background: <span>$col1;
        background: -moz-linear-gradient(top,  $</span>col1 0%, <span>$col2 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,$</span>col1), color-stop(100%,<span>$col2));
        background: -webkit-linear-gradient(top,  $</span>col1 0%,<span>$col2 100%);
        background: -o-linear-gradient(top,  $</span>col1 0%,<span>$col2 100%);
        background: -ms-linear-gradient(top,  $</span>col1 0%,<span>$col2 100%);
        background: linear-gradient(top,  $</span>col1 0%,<span>$col2 100%);
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='$</span>col1', endColorstr='$col2',GradientType=0 );
}

#facebookLogin {
        border: 1px solid #5870ac;
        text-shadow: 1px -1px 1px #5870AC;
        @include socialLoginBackground(#607cb3, #3c62a1);
        &:hover {
                @include socialLoginBackground(#6e8ac1, #426aab);
        }
        &:active {
                @include socialLoginBackground(#375e9e, #5b78b0);
        }
}
```

By using mixins and variables you can avoid the annoying repetition of property blocks so common in large stylesheets.
Better, by defining global variables you can iterate properties such as colors quickly, without constantly using find and replace, which is extremely useful when you're at the prototyping stage of your app.

I found SASS via <a href="http://foundation.zurb.com/" target="_blank">foundation</a>, the responsive css framework I used for prospicious.
They suggest the use of SASS in conjunction with <a href="http://compass-style.org/" target="_blank">compass</a> which is a css authoring framework.
I tried playing around with it but creating a new project resulted in an insane project hierarchy in the filesystem with html files and asset directories when all I wanted was one folder with sass files and one with css to integrate in my existing project.

This appears to be a problem in general with frameworks, they try to do everything for you and you end up with a bloated code base with hundreds of unused lines of code.
Foundation is modular enough that you can just pick whichever parts of it you want in your code and not include the rest.
Perhaps compass offers this as well but I couldn't immediately find it so I stuck with 'normal' SASS and a handmade folder structure which served me well.
