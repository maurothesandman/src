package com.example.sensorapp;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.Socket;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.text.DecimalFormat;

import android.app.Activity;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.Vibrator;
import android.util.Log;
import android.view.Display;
import android.view.Menu;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends Activity implements SensorEventListener {

	private SensorManager mSensorManager;
	private Sensor mLinearAccelerometer;
	private Sensor mRotation;
	private PowerManager mPowerManager;
	private WindowManager mWindowManager;
	private Display mDisplay;
	private WakeLock mWakeLock;

	final private int PORT_NUMBER = 6000;

	float floatRotationX = 0;
	float floatRotationY = 0;
	float floatRotationZ = 0;

	Vibrator vibrator;

	TextView textViewLinearAccX;
	TextView textViewLinearAccY;
	TextView textViewLinearAccZ;

	TextView textViewOrientationX;
	TextView textViewOrientationY;
	TextView textViewOrientationZ;
	TextView textViewOrientationScalar;

	TextView connectionStatus;

	EditText editText1;

	DecimalFormat formatter = new DecimalFormat("@@@");
	long[] pattern = { 0, 200, 500 };

	Socket echoSocket = null;
	PrintWriter out = null;
	BufferedReader in = null;

	String testString = "no";
	Boolean paused = false;

	private static final String TAG = "SensorApp";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		// Get an instance of the SensorManager
		mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
		vibrator = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);

		mLinearAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_LINEAR_ACCELERATION);
		mRotation = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);

		// Get an instance of the PowerManager
		mPowerManager = (PowerManager) getSystemService(POWER_SERVICE);

		// Get an instance of the WindowManager
		mWindowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
		mDisplay = mWindowManager.getDefaultDisplay();

		// Create a bright wake lock
		mWakeLock = mPowerManager.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK, getClass().getName());

		setContentView(R.layout.activity_main);

		textViewLinearAccX = (TextView) findViewById(R.id.linear_acc_x);//linear_acc_x
		textViewLinearAccY = (TextView) findViewById(R.id.linear_acc_y);
		textViewLinearAccZ = (TextView) findViewById(R.id.linear_acc_z);

		textViewOrientationX = (TextView) findViewById(R.id.orientation_x);
		textViewOrientationY = (TextView) findViewById(R.id.orientation_y);
		textViewOrientationZ = (TextView) findViewById(R.id.orientation_z);

		editText1 = (EditText) findViewById(R.id.editText1);

		connectionStatus = (TextView) findViewById(R.id.connection_status);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	protected void onResume() {
		super.onResume();
		
		paused = false;
		/*
		 * when the activity is resumed, we acquire a wake-lock so that the
		 * screen stays on, since the user will likely not be fiddling with the
		 * screen or buttons.
		 */
		mWakeLock.acquire();

		mSensorManager.registerListener(this, mLinearAccelerometer, SensorManager.SENSOR_DELAY_NORMAL); //SensorManager.SENSOR_DELAY_UI
		mSensorManager.registerListener(this, mRotation, SensorManager.SENSOR_DELAY_NORMAL); //SensorManager.SENSOR_DELAY_UI

		new Thread(){
			public void run(){
				testString = "yes";

				String serverHostname = "192.168.1.100";//"128.237.186.192";
				//String serverHostname = new String (editText1.getText().toString().trim());

				Log.e(TAG, "Attempting to connect to host " +
						serverHostname + " on port " + PORT_NUMBER);

				try {
					echoSocket = new Socket(serverHostname, PORT_NUMBER);
					out = new PrintWriter(echoSocket.getOutputStream(), true);
					in = new BufferedReader(new InputStreamReader(
							echoSocket.getInputStream()));

					Log.e(TAG, "Connected to " + serverHostname);
				} catch (UnknownHostException e) {
					Log.e(TAG, "Don't know about host: " + serverHostname);
					System.exit(1);
				} catch (IOException e) {
					Log.e(TAG, "Couldn't get I/O for the connection to: " + serverHostname);
					System.exit(1);
				}

				while (!paused) {

					//out.println("Rx = " + formatter.format(floatRotationX) + ",\tRy = " + formatter.format(floatRotationY) + ",\tRz = " + formatter.format(floatRotationZ));
					out.println((int)(floatRotationZ*180));
					Log.e(TAG, "Sent: " + (int)(floatRotationZ*180));
					
					String userInput;
					try {
						//Log.e(TAG, "Blocked on reading");
						//if ((userInput = in.readLine()) != null && in.ready()) {
						if (in.ready()) {
							//out.println(userInput);
							Log.e(TAG, "Read: " + (byte)in.read());
						} else {
							Log.e(TAG, "in.ready() == false");
							//Log.e(TAG, "in.readLine()) == null");
						}
					} catch (IOException e1) {
						// Auto-generated catch block
						e1.printStackTrace();
					}				

					
					try {
						sleep(50);
					} catch (InterruptedException e) {
						// Auto-generated catch block
						e.printStackTrace();
					}
					
					//Log.w(TAG, "echo: " + in.readLine());
					//System.out.print ("input: ");
				}
			}
		}.start();
	}

	@Override
	protected void onPause() {
		super.onPause();
		
		paused = true;
		
		mSensorManager.unregisterListener(this);

		try {
			out.close();
			in.close();
			echoSocket.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		// and release our wake-lock
		mWakeLock.release();
	}

	@Override
	public void onAccuracyChanged(Sensor arg0, int arg1) {
		// TODO Auto-generated method stub

	}

	@Override
	public void onSensorChanged(SensorEvent event) {

		//String output = formatter.format(value);
		//Log.w(TAG, value + " " + pattern + " " + output);

		if (event.sensor.getType() == Sensor.TYPE_LINEAR_ACCELERATION) {
			float floatLinearAccX = event.values[0];
			float floatLinearAccY = event.values[1];
			float floatLinearAccZ = event.values[2];

			textViewLinearAccX.setText("Linear Acc x = " + formatter.format(floatLinearAccX));
			textViewLinearAccY.setText("Linear Acc y = " + formatter.format(floatLinearAccY));
			textViewLinearAccZ.setText("Linear Acc z = " + formatter.format(floatLinearAccZ));
		} else if (event.sensor.getType() == Sensor.TYPE_ROTATION_VECTOR) {

			floatRotationX = event.values[0];
			floatRotationY = event.values[1];
			floatRotationZ = event.values[2];

			textViewOrientationX.setText("Rotation x = " + formatter.format(floatRotationX));
			textViewOrientationY.setText("Rotation y = " + formatter.format(floatRotationY));
			textViewOrientationZ.setText("Rotation z = " + formatter.format(floatRotationZ));

			if (floatRotationX > 0.5)
				vibrator.vibrate(pattern, 0);
			else
				vibrator.cancel();

		} else
			return;
	}
}
