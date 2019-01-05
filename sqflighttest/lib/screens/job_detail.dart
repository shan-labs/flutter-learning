import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/job.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:intl/intl.dart';

class JobDetail extends StatefulWidget {

	final String appBarTitle;
	final Job job;

	JobDetail(this. job, this.appBarTitle);

	@override
  State<StatefulWidget> createState() {

    return JobDetailState(this.job, this.appBarTitle);
  }
}

class JobDetailState extends State<JobDetail> {

	static var _priorities = ['High', 'Low'];

	DatabaseHelper helper = DatabaseHelper();

	String appBarTitle;
	Job job;

	TextEditingController titleController = TextEditingController();
	TextEditingController descriptionController = TextEditingController();

	JobDetailState(this.job, this.appBarTitle);

	@override
  Widget build(BuildContext context) {

		TextStyle textStyle = Theme.of(context).textTheme.title;

		titleController.text = job.title;
		descriptionController.text = job.description;

    return WillPopScope(

	    onWillPop: () {
	    	// Write some code to control things, when user press Back navigation button in device navigationBar
		    moveToLastScreen();
	    },

	    child: Scaffold(
	    appBar: AppBar(
		    title: Text(appBarTitle),
		    leading: IconButton(icon: Icon(
				    Icons.arrow_back),
				    onPressed: () {
		    	    // Write some code to control things, when user press back button in AppBar
		    	    moveToLastScreen();
				    }
		    ),
	    ),

	    body: Padding(
		    padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
		    child: ListView(
			    children: <Widget>[

			    	// First element
				    ListTile(
					    title: DropdownButton(
							    items: _priorities.map((String dropDownStringItem) {
							    	return DropdownMenuItem<String> (
									    value: dropDownStringItem,
									    child: Text(dropDownStringItem),
								    );
							    }).toList(),

							    style: textStyle,

							    value: getPriorityAsString(job.priority),

							    onChanged: (valueSelectedByUser) {
							    	setState(() {
							    	  debugPrint('User selected $valueSelectedByUser');
							    	  updatePriorityAsInt(valueSelectedByUser);
							    	});
							    }
					    ),
				    ),

				    // Second Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: titleController,
						    style: textStyle,
						    onChanged: (value) {
						    	debugPrint('Something changed in Title Text Field');
						    	updateTitle();
						    },
						    decoration: InputDecoration(
							    labelText: 'Title',
							    labelStyle: textStyle,
							    border: OutlineInputBorder(
								    borderRadius: BorderRadius.circular(5.0)
							    )
						    ),
					    ),
				    ),

				    // Third Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: TextField(
						    controller: descriptionController,
						    style: textStyle,
						    onChanged: (value) {
							    debugPrint('Something changed in Description Text Field');
							    updateDescription();
						    },
						    decoration: InputDecoration(
								    labelText: 'Description',
								    labelStyle: textStyle,
								    border: OutlineInputBorder(
										    borderRadius: BorderRadius.circular(5.0)
								    )
						    ),
					    ),
				    ),

				    // Fourth Element
				    Padding(
					    padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
					    child: Row(
						    children: <Widget>[
						    	Expanded(
								    child: RaisedButton(
									    color: Theme.of(context).primaryColorDark,
									    textColor: Theme.of(context).primaryColorLight,
									    child: Text(
										    'Save',
										    textScaleFactor: 1.5,
									    ),
									    onPressed: () {
									    	setState(() {
									    	  debugPrint("Save button clicked");
									    	  _save();
									    	});
									    },
								    ),
							    ),

							    Container(width: 5.0,),

							    Expanded(
								    child: RaisedButton(
									    color: Theme.of(context).primaryColorDark,
									    textColor: Theme.of(context).primaryColorLight,
									    child: Text(
										    'Delete',
										    textScaleFactor: 1.5,
									    ),
									    onPressed: () {
										    setState(() {
											    debugPrint("Delete button clicked");
											    _delete();
										    });
									    },
								    ),
							    ),

						    ],
					    ),
				    ),

			    ],
		    ),
	    ),

    ));
  }

  void moveToLastScreen() {
		Navigator.pop(context, true);
  }

	// Convert the String priority in the form of integer before saving it to Database
	void updatePriorityAsInt(String value) {
		switch (value) {
			case 'High':
				job.priority = 1;
				break;
			case 'Low':
				job.priority = 2;
				break;
		}
	}

	// Convert int priority to String priority and display it to user in DropDown
	String getPriorityAsString(int value) {
		String priority;
		switch (value) {
			case 1:
				priority = _priorities[0];  // 'High'
				break;
			case 2:
				priority = _priorities[1];  // 'Low'
				break;
		}
		return priority;
	}

	// Update the title of Job object
  void updateTitle(){
    job.title = titleController.text;
  }

	// Update the description of Job object
	void updateDescription() {
		job.description = descriptionController.text;
	}

	// Save data to database
	void _save() async {

		moveToLastScreen();

		job.date = DateFormat.yMMMd().format(DateTime.now());
		int result;
		if (job.id != null) {  // Case 1: Update operation
			result = await helper.updateJob(job);
		} else { // Case 2: Insert Operation
			result = await helper.insertJob(job);
		}

		if (result != 0) {  // Success
			_showAlertDialog('Status', 'Job Saved Successfully');
		} else {  // Failure
			_showAlertDialog('Status', 'Problem Saving Job');
		}

	}

	void _delete() async {

		moveToLastScreen();

		// Case 1: If user is trying to delete the NEW JOB i.e. he has come to
		// the detail page by pressing the FAB of JobList page.
		if (job.id == null) {
			_showAlertDialog('Status', 'No Job was deleted');
			return;
		}

		// Case 2: User is trying to delete the old job that already has a valid ID.
		int result = await helper.deleteJob(job.id);
		if (result != 0) {
			_showAlertDialog('Status', 'Job Deleted Successfully');
		} else {
			_showAlertDialog('Status', 'Error Occured while Deleting Job');
		}
	}

	void _showAlertDialog(String title, String message) {

		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}

}










