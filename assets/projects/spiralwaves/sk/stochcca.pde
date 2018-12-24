int width = 400;
int height = 400;

int [][] x;
int [][] y;
int V = 15;
float p1 = 0.8f;
float p2 = 0.4f;
float p3 = 0f;
void setup() {
	size(400, 400);
	frameRate(30);
	x = new int[width][height];
	y = new int[width][height];
    randReset();
}
void draw() {
	for (int i = 0; i < width ; i ++) {
		int i1 = (i == 0) ? width - 1 : i - 1;
		int i2 = (i == width - 1) ? 0 : i + 1;
		for (int j = 0; j < height ; j ++) {
			int j1 = (j == 0) ? height - 1 : j - 1;
			int j2 = (j == height - 1) ? 0 : j + 1;
			int next = (x[i][j] + 1) % V;
			boolean test2 = x[i1][j1] == next || x[i2][j1] == next || x[i1][j2] == next || x[i2][j2] == next;
			boolean test1 = x[i][j1] == next || x[i][j2] == next || x[i1][j] == next || x[i2][j] == next;
			float r3 = random(0,1);
			float r2 = random(0,1);
			float r1 = random(0,1);
			if((test1 && r1 < p1) || (test2 && r2 < p2) || r3 < p3) {
				y[i][j] = next;
			} else {
				y[i][j] = x[i][j];
			}
		}
	}
	
	for (int i = 0; i < width ; i ++) {
		for (int j = 0; j < height ; j ++) {
			x[i][j] = y[i][j];
			int p = (int) ((1 - (float)x[i][j]/(float)V) * 255);
			set (i, j, color(p, p, p));
		}
	}
}

void randReset() {
	for (int i = 0; i < width ; i ++) {
		for (int j = 0; j < height ; j ++) {
			x[i][j] = (int) random(0,V);
		}
	}
}

void mousePressed() {

}

void mouseMoved() {

}

void keyPressed() {
	switch((int)key) {
	case 114:
		randReset();
		break;
	
	}
}