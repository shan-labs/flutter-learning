import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/job.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:flutter_app/screens/job_detail.dart';
import 'package:sqflite/sqflite.dart';


class JobList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {

    return JobListState();
  }
}

class JobListState extends State<JobList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Job> jobList;
	int count = 0;

	@override
  Widget build(BuildContext context) {

		if (jobList == null) {
			jobList = List<Job>();
			updateListView();
		}

    return Scaffold(

	    appBar: AppBar(
		    title: Text('Jobs'),
	    ),

	    body: getJobListView(),

	    floatingActionButton: FloatingActionButton(
		    onPressed: () {
		      debugPrint('FAB clicked');
		      navigateToDetail(Job('', '', 2), 'Add Job');
		    },

		    tooltip: 'Add Job',

		    child: Icon(Icons.add),

	    ),
    );
  }

  ListView getJobListView() {

		TextStyle titleStyle = Theme.of(context).textTheme.subhead;

		return ListView.builder(
			itemCount: count,
			itemBuilder: (BuildContext context, int position) {
				return Card(
					color: Colors.white,
					elevation: 2.0,
					child: ListTile(

						leading: CircleAvatar(
							backgroundColor: getPriorityColor(this.jobList[position].priority),
							child: getPriorityIcon(this.jobList[position].priority),
						),

						title: Text(this.jobList[position].title, style: titleStyle,),

						subtitle: Text(this.jobList[position].date),

						trailing: GestureDetector(
							child: Icon(Icons.delete, color: Colors.grey,),
							onTap: () {
								_delete(context, jobList[position]);
							},
						),


						onTap: () {
							debugPrint("ListTile Tapped");
							navigateToDetail(this.jobList[position],'Edit Job');
						},

					),
				);
			},
		);
  }

  // Returns the priority color
	Color getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.red;
				break;
			case 2:
				return Colors.yellow;
				break;

			default:
				return Colors.yellow;
		}
	}

	// Returns the priority icon
	Icon getPriorityIcon(int priority) {
		switch (priority) {
			case 1:
				return Icon(Icons.play_arrow);
				break;
			case 2:
				return Icon(Icons.keyboard_arrow_right);
				break;

			default:
				return Icon(Icons.keyboard_arrow_right);
		}
	}

	void _delete(BuildContext context, Job job) async {

		int result = await databaseHelper.deleteJob(job.id);
		if (result != 0) {
			_showSnackBar(context, 'Job Deleted Successfully');
			updateListView();
		}
	}

	void _showSnackBar(BuildContext context, String message) {

		final snackBar = SnackBar(content: Text(message));
		Scaffold.of(context).showSnackBar(snackBar);
	}

  void navigateToDetail(Job job, String title) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return JobDetail(job, title);
	  }));

	  if (result == true) {
	  	updateListView();
	  }
  }

  void updateListView() {

		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {

			Future<List<Job>> jobListFuture = databaseHelper.getJobList();
			jobListFuture.then((jobList) {
				setState(() {
				  this.jobList = jobList;
				  this.count = jobList.length;
				});
			});
		});
  }
}







