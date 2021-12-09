extends Reference
class_name Bezier



static func quadratic(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	return (1 - t) * ((1 - t) * p0 + t * p1) + t * ((1 - t) * p1 + t * p2)


static func quadratic_segments(p0 : Vector2, p1 : Vector2, p2: Vector2, nr_of_segments : int) -> Array:
	var segment_borders = [{"pos": p0, "length" : 0}]
	var total_len : float = 0.0
	var prev_point = quadratic(p0, p1, p2, 0)
	for i in range(1, nr_of_segments + 1):
		var point = quadratic(p0, p1, p2, float(i) / nr_of_segments)
		var dist = (point - prev_point).length()
		total_len += dist
		segment_borders.append({"length": total_len, "pos": point})
		prev_point = point
	return segment_borders
