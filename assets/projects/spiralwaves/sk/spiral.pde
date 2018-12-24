int width = 400;
int height = 400;

int [][] x;
int [][] K;
int [][] ill;
int [][] s;
int k1 = 2;
int k2 = 3;
int g = 20;
int V = 100;
void setup() {
	size(400, 400);
	frameRate(30);
	x = new int[width][height];
    K = new int[width][height];
    ill = new int[width][height];
    s = new int[width][height];
    randReset();
}
void draw() {
	for (int i = 0; i < width ; i ++) {
		for (int j = 0; j < height ; j ++) {
			K[i][j] = ill[i][j] = s[i][j] = 0;
		}
	}
	for (int i = 0; i < width ; i ++) {
		int i1 = (i == 0) ? width - 1 : i - 1;
		int i2 = (i == width - 1) ? 0 : i + 1;
		for (int j = 0; j < height ; j ++) {
			int j1 = (j == 0) ? height - 1 : j - 1;
			int j2 = (j == height - 1) ? 0 : j + 1;
			if (x[i][j] == V) {
				K[i1][j1] += 1;
				K[i1][j ] += 1;
				K[i1][j2] += 1;
				K[i ][j1] += 1;
				K[i ][j2] += 1;
				K[i2][j1] += 1;
				K[i2][j ] += 1;
				K[i2][j2] += 1;
				K[i ][j ] += 1;
			} else if (x[i][j] < V && x[i][j] > 0) {
				ill[i1][j1] += 1;
				ill[i1][j ] += 1;
				ill[i1][j2] += 1;
				ill[i ][j1] += 1;
				ill[i ][j2] += 1;
				ill[i2][j1] += 1;
				ill[i2][j ] += 1;
				ill[i2][j2] += 1;
				ill[i ][j ] += 1;
				s[i1][j1] += x[i][j];
				s[i1][j ] += x[i][j];
				s[i1][j2] += x[i][j];
				s[i ][j1] += x[i][j];
				s[i ][j2] += x[i][j];
				s[i2][j1] += x[i][j];
				s[i2][j ] += x[i][j];
				s[i2][j2] += x[i][j];
				s[i ][j ] += x[i][j];
			}
		}
	}

	for (int i = 0; i < width ; i ++) {
		for (int j = 0; j < height ; j ++) {
			if (x[i][j] == V) {
				x[i][j] = 0;
			} else if (x[i][j] == 0) {
				x[i][j] = (int)(K[i][j]/k1)+(int)(ill[i][j]/k2);
			} else {
				x[i][j] = constrain((int)(s[i][j]/ill[i][j])+g,0,V);
			}
			int p = (x[i][j] == 0) ? 255 : 0;
			//int p = (int) ((1 - (float)x[i][j]/(float)V) * 255);
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

static void main(String args[]) {
	PApplet.main(new String[] { "--present", "String" });
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
	case 49:
		k1 = ((k1 + 1) % 20);
		break;
	case 50:
		k2 = ((k2 + 1) % 20);
		break;
	case 51:
		g = ((g + 1) % 30);
		break;
	case 52:
		g = ((g - 1) % 30);
		break;	
	}
	if(k1 == 0) k1 = 1;
	if(k2 == 0) k2 = 1;
}
