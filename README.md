# Translation Matrix
```
makeTrans(Vector3 t)
```
## 功能：
給定一個向量 t，返回對應的 4x4 平移矩陣。


## 操作思路：

平移矩陣在齊次座標下的形式是：

<img width="293" height="140" alt="image" src="https://github.com/user-attachments/assets/95741538-4068-460a-93b7-81446cac6f29" />

```
void makeTrans(Vector3 t) {
    makeIdentity();   // 先設成單位矩陣
    m[3]  = t.x;      // 第1列最後一格 → tx
    m[7]  = t.y;      // 第2列最後一格 → ty
    m[11] = t.z;      // 第3列最後一格 → tz
  }
```

# Rotation Matrix (Z-axis)
```
makeRotZ(float a)
```
## 功能：
返回繞 Z 軸旋轉角度 a 的 4x4 矩陣。


## 操作思路：

旋轉角度 𝑎（單位：弧度），矩陣為：

<img width="316" height="129" alt="image" src="https://github.com/user-attachments/assets/d9f46024-59fe-4723-bf7b-c94018d79c3d" />


```
void makeRotZ(float a) {
     // TODO HW2
     // You need to implement the rotation of z-axis matrix here. (Yaw)
    makeIdentity();   // 先設成單位矩陣
    float c = cos(a);
    float s = sin(a);

    m[0] = c;   m[1] = -s;  m[2] = 0;  m[3] = 0;
    m[4] = s;   m[5] =  c;  m[6] = 0;  m[7] = 0;
    m[8] = 0;   m[9] =  0;  m[10]= 1;  m[11]= 0;
    m[12]= 0;   m[13]= 0;   m[14]= 0;  m[15]= 1;
  }
```

# Scaling Matrix
```
makeScale(Vector3 s)
```
## 功能：
返回縮放向量 s 的 4x4 矩陣。


## 操作思路：

縮放矩陣在齊次座標下的形式是：

<img width="314" height="143" alt="image" src="https://github.com/user-attachments/assets/c0ed1499-23e7-446d-b7b6-c9585a44dcb9" />


```
void makeScale(Vector3 s) {
    // TODO HW2
    // You need to implement the scale matrix here.
    makeIdentity();   // 先設成單位矩陣
    m[0]  = s.x;      // x 軸縮放
    m[5]  = s.y;      // y 軸縮放
    m[10] = s.z;      // z 軸縮放
  }
```

# Point in Polygon, pnpoly
```
pnpoly(float x, float y, Vector3[] vertexes)
```
## 功能：
判斷點是否在多邊形內，常用射線法 (Ray Casting)


## 操作思路：

用 Ray Casting Algorithm（射線法）：從點向右射一條水平射線，計算與多邊形邊界的交點數。若交點數為奇數 → 在內部；偶數 → 在外部。


```
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
```

# Bounding Box
```
findBoundBox(Vector3[] v) 
```
## 功能：
計算多邊形邊界框


## 操作思路：

找出所有頂點的最小/最大 x, y 值。


```
public Vector3[] findBoundBox(Vector3[] v) {
    
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
```

# Sutherland–Hodgman 多邊形裁剪
```
Sutherland_Hodgman_algorithm(Vector3[] points,Vector3[] boundary)
```
## 功能：
使圖形不超出畫布範圍。


## 操作思路：

1. 初始輸入多邊形頂點集合 inputList
2. 對於每條邊界，建立新的 outputList
3. 對 inputList 的每條邊 (S→P)：
  若 P 在內部且 S 在內部 → 輸出 P
  若 P 在內部且 S 在外部 → 輸出交點 + P
  若 P 在外部且 S 在內部 → 輸出交點
  若 P 在外部且 S 在外部 → 不輸出
4. 最後 outputList 即為裁剪後的多邊形


```
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
```

##結果畫面截圖
<img width="1242" height="742" alt="image" src="https://github.com/user-attachments/assets/e6a1f031-51b8-4544-a974-464d96c610c1" />
