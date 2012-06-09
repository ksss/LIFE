window.onload = (function(){
    
    if (!(typeof document.body.style.maxHeight != "undefined")) {
        location.replace("http://www.theie6countdown.com/default.aspx");
    }

    var text   = document.getElementById('text1');
    var button = document.getElementById('button');
    var speed  = document.getElementById('speed');
    
    var view  = new View({
        canvasWidth  : 700,
        canvasHeight : 700
    });
    
    var world = World.DefaultSet(
        100,  //canvasWidhtで割り切れる数安定
        100,
        text.value
    );
    
    var godhand = new GodHand(view, world);
    
    //var canv   = document.getElementById('canvas');
    var canv   = view.canvas;
    
    canv.addEventListener('mousedown', function (e) {
        window.event = e; //for firefox
        godhand.mousedown();
    }, false);
    
    canv.addEventListener('mousemove', function (e) {
        window.event = e;
        godhand.mousemove();
    }, false);
    
    canv.addEventListener('mouseup', function () {
        godhand.mouseup();
    }, false);
    
    //一時停止実装
    button.addEventListener('click', function () {
        if (button.innerHTML == "start") {
            button.innerHTML = "stop";
        } else if (button.innerHTML == "stop") {
            button.innerHTML = "start";
        }
    }, false);
    

    setTimeout(function () { try {
        view.show(world);
        if (button.innerHTML == "stop") world.next();
        setTimeout(arguments.callee, speed.value);
    } catch (e) { log(e) }}, speed.value);
    
});


World = function () {
    this.init.apply(this, arguments);
}
World.prototype = {
    width  : 0,
    height : 0,
    pool   : [],
    
    init : function (width, height){
        this.width  = width;
        this.height = height;
        this.pool   = this.newPool();
    },
    
    newPool : function () {
        var ret = new Array(this.width);
        for (var y = 0; y < this.height; y++) {
            ret[y] = new Array(this.height);
            for (var x = 0; x < this.width; x++) {
                ret[y][x] = false;
            }
        }
        return ret;
    },
    
    next : function () {
        var pool = this.newPool();
        for (var y = 0; y < this.height; y++) {
            for (var x = 0; x < this.width; x++) {
                pool[y][x] = this.nextStatus(y, x);
            }
        }
        this.pool = pool;
    },
    
    nextStatus : function (y, x) {
        var round = 0;
        var cells = this.pool;
          
        var cell = function (y, x) {
            return (cells[y] || {})[x] || false;
        };
      
        round += cell(y - 1,x - 1) + cell(y - 1,x    ) + cell(y - 1,x + 1);
        round += cell(y    ,x - 1)                     + cell(y    ,x + 1);
        round += cell(y + 1,x - 1) + cell(y + 1,x    ) + cell(y + 1,x + 1);
        
        // Rule of Life
        return (round == 3) ? true :
               (round == 2) ? cell(y, x) :
               false;
    }
}
World.DefaultSet = function (width, height, str) {
    var world = new World(width, height);
    var lines = str.split(/\n/);

    for (var y = 0, yl = lines.length; y < yl; y++) {
        var line = lines[y];
        for (var x = 0, xl = line.length; x < xl; x++) {
            world.pool[y][x] = (line.charAt(x) == "■") ? true : false
        }
    }
    return world;
}


GodHand = function () {
    this.init.apply(this, arguments);
}
GodHand.prototype = {
    on   : false,
    mode : true,
    hy   : 0,
    hx   : 0,
    
    init : function (view, world) {
        this.view  = view;
        this.world = world;
    },

    mousedown : function () {
        this.getClickPoint();
        this.on = true;
        this.mode = this.world.pool[this.hy][this.hx] ? false : true
        this.world.pool[this.hy][this.hx] = this.mode;
    },
    
    mousemove : function () {
        if(!this.on) return;
        this.getClickPoint();
        this.world.pool[this.hy][this.hx] = this.mode;
    },
    
    mouseup : function () {
        this.on = false;
    },

    getClickPoint : function () {
        var e = window.event;
        var size = cut(this.view.opt.canvasWidth / this.world.width);
        
        //safari firefox の event 吸収
        var offsetX = e.offsetX || (e.pageX - e.target.offsetLeft);
        var offsetY = e.offsetY || (e.pageY - e.target.offsetTop);
        
        var setlimit = function (value, max) {
            if (value < 0)   value = 0;
            if (value > max) value = max;        
            return cut(value);
        };
        
        this.hx = setlimit((offsetX / size), this.world.width  - 1);
        this.hy = setlimit((offsetY / size), this.world.height - 1);
    }
}


View = function () {
    this.init.apply(this,arguments);
}
View.prototype = {
    canvas : null,
    ctx    : null,
    opt    : [],
    
    init : function (opt) {
        //初期値
        this.opt = {
            canvasWidth  : 600,
            canvasHeight : 600,
            parent       : document.getElementById('result')
        };
        
        //オプションをマージ
        for (var k in opt) if (opt.hasOwnProperty(k)) {
            this.opt[k] = opt[k];
        }
        
        this.canvas = document.createElement('canvas');
        this.canvas.setAttribute('width' ,this.opt.canvasWidth);
        this.canvas.setAttribute('height',this.opt.canvasHeight);
        this.canvas.id = 'canvas';
        this.opt.parent.appendChild(this.canvas);
        this.ctx = this.canvas.getContext('2d');
    },
    
    show : function (world) {
        var size = cut(this.opt.canvasWidth / world.width);
        
        this.ctx.clearRect(0, 0, this.opt.canvasWidth, this.opt.canvasHeight);
        
        this.grid(this.opt.canvasWidth, this.opt.canvasHeight, size);

        for (var y = 0; y < world.height; y++) {
            for (var x = 0; x < world.width; x++) {
                if (world.pool[y][x]){
                    var r = Math.floor(x / world.width  * 255);
                    var g = Math.floor(y / world.height * 255);
                    var b = Math.floor(255 - ((x * y) / (world.width * world.height)) * 255);

                    this.ctx.fillStyle = 'rgba(' + r + ',' + g + ',' + b + ',0.5)';
                    this.ctx.fillRect(x * size, y * size, size, size);
                }
            }
        }
    },
    
    grid : function (y, x, size) { //5ms
        this.ctx.lineWidth = 0.1;
        this.ctx.strokeStyle = 'rgb(100,100,100)';

        this.ctx.beginPath();
        for (var i = size; i < y; i += size) {
            this.ctx.moveTo(0, i);
            this.ctx.lineTo(x, i);
        }
        for (var j = size; j < x; j += size) {
            this.ctx.moveTo(j, 0);
            this.ctx.lineTo(j, y);
        }
        this.ctx.stroke();
    }
}

function cut (num) {
    return Math.floor(num);
}

function log () {
    if (console && console.log) {
        console.log(Array.prototype.slice.apply(arguments));
    }
}
