public void CGLine(float x1, float y1, float x2, float y2) {
    // TODO HW1
    // Please paste your code from HW1 CGLine.
    int x = int(x1);
    int y = int(y1);
    int dx = abs(int(x2 - x1));
    int dy = abs(int(y2 - y1));
    int sx = (x1 < x2) ? 1 : -1;
    int sy = (y1 < y2) ? 1 : -1;
    int err = dx - dy;

    while (true) {
        drawPoint(x, y, color(0)); // 在像素陣列上畫點
        if (x == int(x2) && y == int(y2)) break;

        int e2 = 2 * err;
        if (e2 > -dy) {
            err -= dy;
            x += sx;
        }
        if (e2 < dx) {
            err += dx;
            y += sy;
        }
    }
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
    boolean inside = false;
    int n = vertexes.length;

    for (int i = 0, j = n - 1; i < n; j = i++) {
        float xi = vertexes[i].x();
        float yi = vertexes[i].y();
        float xj = vertexes[j].x();
        float yj = vertexes[j].y();

        // 避免除以零，加一個小 epsilon
        float denom = (yj - yi);
        if (Math.abs(denom) < 1e-6f) continue; // 水平邊直接跳過

        boolean intersect = ((yi > y) != (yj > y)) &&
                            (x < (xj - xi) * (y - yi) / denom + xi);

        if (intersect) inside = !inside;
    }

    return inside;
}


public Vector3[] findBoundBox(Vector3[] v) {
    
    
    // TODO HW2 
    // You need to find the bounding box of the vertices v.
    // r1 -------
    //   |   /\  |
    //   |  /  \ |
    //   | /____\|
    //    ------- r2

    if (v == null || v.length == 0) {
        return new Vector3[]{ new Vector3(0,0,0), new Vector3(0,0,0) };
    }

    float minX = v[0].x();
    float maxX = v[0].x();
    float minY = v[0].y();
    float maxY = v[0].y();

    for (int i = 1; i < v.length; i++) {
        float x = v[i].x();
        float y = v[i].y();

        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
    }

    return new Vector3[]{
        new Vector3(minX, minY, 0),   // 左下角
        new Vector3(maxX, maxY, 0)    // 右上角
    };

}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i++) {
        input.add(points[i]);
    }

    // 逐邊界裁切
    for (int j = 0; j < boundary.length; j++) {
        ArrayList<Vector3> output = new ArrayList<Vector3>();
        Vector3 A = boundary[j];
        Vector3 B = boundary[(j + 1) % boundary.length];

        for (int i = 0; i < input.size(); i++) {
            Vector3 P = input.get(i);
            Vector3 Q = input.get((i + 1) % input.size());

            boolean Pin = inside(P, A, B);
            boolean Qin = inside(Q, A, B);

            if (Pin && Qin) {
                // P、Q 都在內部 → 保留 Q
                output.add(Q);
            } else if (Pin && !Qin) {
                // P 在內、Q 在外 → 加入交點
                output.add(intersection(P, Q, A, B));
            } else if (!Pin && Qin) {
                // P 在外、Q 在內 → 加入交點與 Q
                output.add(intersection(P, Q, A, B));
                output.add(Q);
            }
            // P、Q 都在外 → 不加
        }
        input = output;
        if (input.isEmpty()) break;
    }

    Vector3[] result = new Vector3[input.size()];
    for (int i = 0; i < input.size(); i++) {
        result[i] = input.get(i);
    }
    return result;
}

// 判斷點是否在邊界內側
private boolean inside(Vector3 p, Vector3 a, Vector3 b) {
    // (b - a) × (p - a) 的 z > 0 表示 p 在邊界內側
    return ((b.x() - a.x()) * (p.y() - a.y()) -
        (b.y() - a.y()) * (p.x() - a.x())) < 0;

}


// 計算線段 PQ 與邊界 AB 的交點
private Vector3 intersection(Vector3 p, Vector3 q, Vector3 a, Vector3 b) {
    float A1 = q.y() - p.y();
    float B1 = p.x() - q.x();
    float C1 = A1 * p.x() + B1 * p.y();

    float A2 = b.y() - a.y();
    float B2 = a.x() - b.x();
    float C2 = A2 * a.x() + B2 * a.y();

    float det = A1 * B2 - A2 * B1;
    if (abs(det) < 1e-6) {
        return p; // 平行，直接回傳 P
    }
    float x = (B2 * C1 - B1 * C2) / det;
    float y = (A1 * C2 - A2 * C1) / det;
    return new Vector3(x, y, 0);
}
