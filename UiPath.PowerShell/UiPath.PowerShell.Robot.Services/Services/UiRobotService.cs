using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UiPath.PowerShell.Robot.Models;

namespace UiPath.PowerShell.Robot.Services
{
    public class UiRobotService : IUiRobotService
    {
        public async Task<UiRobotJobDto> RunJob(RunUiRobotJobCommand input)
        {
            var taskSource = new TaskCompletionSource<UiRobotJobDto>();

            taskSource.SetResult(new UiRobotJobDto
            {
                ProcessId = 1
            });

            return await taskSource.Task;
        }
    }
}
