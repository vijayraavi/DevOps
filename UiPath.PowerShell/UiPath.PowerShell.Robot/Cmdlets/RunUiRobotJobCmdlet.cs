using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using UiPath.PowerShell.Robot.Models;
using UiPath.PowerShell.Robot.Services;

namespace UiPath.PowerShell.Robot.Cmdlets
{
    [Cmdlet(VerbsCommon.New, "UiRobotJob")]
    [OutputType(typeof(UiRobotJobDto))]
    public class RunUiRobotJobCmdlet: Cmdlet
    {
        [Parameter(Mandatory = true)]
        public string ProjectJsonPath { get; set; }

        private IUiRobotService _uiRobotService;

        public RunUiRobotJobCmdlet()
        {
            _uiRobotService = new UiRobotService();
        }

        protected override void ProcessRecord()
        {
            var runJobTask = _uiRobotService.RunJob(new RunUiRobotJobCommand
            {
                ProjectJsonPath = ProjectJsonPath
            });

            runJobTask.Wait();

            WriteObject(runJobTask.Result);
        }
    }
}
