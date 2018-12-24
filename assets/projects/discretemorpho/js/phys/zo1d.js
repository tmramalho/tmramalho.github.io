/* Convenience functions */
function newFilledArray(length, val) {
	var array = [];
	for (var i = 0; i < length; i++) {
		array[i] = val;
	}
	return array;
}

function addSaltAndPepper(array, p) {
	for (var i = 0; i < array.length; i++) {
		if(Math.random() < p) {
			if(array[i] == 0) array[i] = 1;
			else array[i] = 0;
		}
	}
}

function setRule(ruleID) {
	transition = newFilledArray(32, 0);
	for (var i = 0; i < 32; i++) {
		transition[i] = (ruleID & 1);
		ruleID >>= 1;
	}
}

/* Initial constants */
lx = 100;
ly = 50;
th = 4;
sig = 0.01;
grad = 50;
lattice = newFilledArray(lx*ly, 0);
addSaltAndPepper(lattice, sig);
setRule(34);

/* cellular automaton */
function calcTimeStep(lattice, th) {
	newLattice = [];
	for(var i = 0; i < ly; i++) {
		for(var j = 0; j < lx; j++) {
			acc = 0;
			if(i > 0)                        acc += lattice[(i-1)*lx + j  ];
			if(i > 0 && j > 0)               acc += lattice[(i-1)*lx + j-1];
			if(i > 0 && j < (lx - 1))        acc += lattice[(i-1)*lx + j+1];
			if(j > 0)                        acc += lattice[ i   *lx + j-1];
			if(j < (lx - 1))                 acc += lattice[ i   *lx + j+1];
			if(i < (ly - 1))                 acc += lattice[(i+1)*lx + j  ];
			if(i < (ly - 1) && j > 0)        acc += lattice[(i+1)*lx + j-1];
			if(i < (ly - 1) && j < (lx - 1)) acc += lattice[(i+1)*lx + j+1];
			m = 0;
			if(acc > th) {
				m = 1;
			}
			xi = 0;
			if(j > grad) {
				xi = 1;
			}
			input = lattice[i*lx + j] | m << 1 | xi << 2;
			newLattice[i*lx + j] = transition[input];
		}
	}
	return newLattice;
}

/* Main code */
function sketchProc(processing) {
	processing.setup = function() {
		processing.size(600,400);
		processing.background(235);
		processing.frameRate(10);
		processing.noLoop();
	}
	processing.draw = function() {
		processing.noStroke();
		rw = processing.width/lx;
		rh = processing.height/ly;
		lattice = calcTimeStep(lattice, th);
		addSaltAndPepper(lattice, sig);
		for(var i = 0; i < ly; i++) {
			for(var j = 0; j < lx; j++) {
				if(lattice[i*lx + j] == 0) {
					processing.fill(255);
				} else {
					processing.fill(60);
				}
				processing.rect(j*rw, i*rh, rw, rh);
			}
		}
	}
	
	processing.mouseClicked = function() {
		var i = Math.floor(processing.mouseX * lx / processing.width);
		var j = Math.floor(processing.mouseY * ly / processing.height);
		if(lattice[i*lx + j] == 0) lattice[i*lx + j] = 1;
		else lattice[i*lx + j] = 0;
		if(lattice[i*lx + j] == 0) {
			processing.fill(255);
		} else {
			processing.fill(0);
		}
		processing.rect(i*rw, j*rh, rw, rh);
	}
}

/* Setup */
var canvas = $("#procCanvas").get(0);
var p = new Processing(canvas, sketchProc);

/* interactivity */

$("#ruleType").keyup(function(e){
	trial = parseInt($(this).val());
	if(trial < 256 && trial >= 0) {
		setRule(trial);
	}
});

$("#gradType").keyup(function(e){
	trial = parseInt($(this).val());
	if(trial < 100 && trial >= 0) {
		grad = trial;
	}
});

$("#sigType").keyup(function(e){
	trial = parseFloat($(this).val());
	if(trial < 1 && trial >= 0) {
		sig = trial;
	}
});

$("#thType").keyup(function(e){
	trial = parseInt($(this).val());
	if(trial < 9 && trial >= 0) {
		th = trial;
	}
});

$("#playType").change(function(e){
	play = $("#playType").prop("checked");
	if(play) {
		p.loop();
	} else {
		p.noLoop();
	}
});

$("#stepType").click(function(e){
	$("#playType").prop("checked", false);
	p.noLoop();
	p.draw();
});

$("#fullStepType").click(function(e){
	$("#playType").prop("checked", false);
	p.noLoop();
	for(var i = 0; i < 99; i++) {
		lattice = calcTimeStep(lattice, th);
	}
	p.draw();
});

$("#resetType").click(function(e){
	$("#playType").prop("checked", false);
	lattice = newFilledArray(lx*ly, 0);
	p.noLoop();
	p.draw();
});

$(".cPanel").submit(function(){
	return false;
});