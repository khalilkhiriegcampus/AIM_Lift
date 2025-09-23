def classify_incident(sensor_data):
    if sensor_data.get("cabin_status") == "stuck":
        return {"type": "Mantrap", "severity": "High"}
    if sensor_data.get("door_status") == "jammed":
        return {"type": "Door Jam", "severity": "Medium"}
    if sensor_data.get("speed", 0) > 3 and sensor_data.get("power") == "off":
        return {"type": "Lift Fall", "severity": "Critical"}
    if sensor_data.get("power") == "failure":
        return {"type": "Power Failure", "severity": "High"}
    return {"type": "Normal", "severity": "Low"}
