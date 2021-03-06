
import 'dart:math';

class KalmanLatLong {

  double minAccuracy = 1;

	double q_metres_per_second;
	int timeStamp_milliseconds;
	double lat;
	double lng;
	double variance; 

  int consecutiveRejectCount;

  KalmanLatLong(double q_metres_per_second) {
		this.q_metres_per_second = q_metres_per_second;
		variance = -1;
		consecutiveRejectCount = 0;
	}
	
  int get_TimeStamp() {
		return timeStamp_milliseconds;
	}

	double get_lat() {
		return lat;
	}

	double get_lng() {
		return lng;
	}

	double get_accuracy() {
		return sqrt(variance);
	}

	void setState(double lat, double lng, double accuracy,
			int timeStamp_milliseconds) {
		this.lat = lat;
		this.lng = lng;
		variance = accuracy * accuracy;
		this.timeStamp_milliseconds = timeStamp_milliseconds;
	}

	// / <summary>
	// / Kalman filter processing for lattitude and longitude
	// / </summary>
	// / <param name="lat_measurement_degrees">new measurement of
	// lattidude</param>
	// / <param name="lng_measurement">new measurement of longitude</param>
	// / <param name="accuracy">measurement of 1 standard deviation error in
	// metres</param>
	// / <param name="TimeStamp_milliseconds">time of measurement</param>
	// / <returns>new state</returns>
	void Process(double lat_measurement, double lng_measurement,
			double accuracy, int timeStamp_milliseconds, double q_metres_per_second) {
		this.q_metres_per_second = q_metres_per_second;
		
		if (accuracy < minAccuracy)
			accuracy = minAccuracy;
		if (variance < 0) {
			// if variance < 0, object is unitialised, so initialise with
			// current values
			this.timeStamp_milliseconds = timeStamp_milliseconds;
			lat = lat_measurement;
			lng = lng_measurement;
			variance = accuracy * accuracy;
		} else {
			// else apply Kalman filter methodology

			int timeInc_milliseconds = timeStamp_milliseconds
					- this.timeStamp_milliseconds;
			if (timeInc_milliseconds > 0) {
				// time has moved on, so the uncertainty in the current position
				// increases
				variance += timeInc_milliseconds * q_metres_per_second
						* q_metres_per_second / 1000;
				this.timeStamp_milliseconds = timeStamp_milliseconds;
				// TO DO: USE VELOCITY INFORMATION HERE TO GET A BETTER ESTIMATE
				// OF CURRENT POSITION
			}

			// Kalman gain matrix K = Covarariance * Inverse(Covariance +
			// MeasurementVariance)
			// NB: because K is dimensionless, it doesn't matter that variance
			// has different units to lat and lng
			double K = variance / (variance + accuracy * accuracy);
			// apply K
			lat += K * (lat_measurement - lat);
			lng += K * (lng_measurement - lng);
			// new Covarariance matrix is (IdentityMatrix - K) * Covarariance
			variance = (1 - K) * variance;
		}
	}

	int getConsecutiveRejectCount() {
		return consecutiveRejectCount;
	}

	void setConsecutiveRejectCount(int consecutiveRejectCount) {
		this.consecutiveRejectCount = consecutiveRejectCount;
	}
  
}