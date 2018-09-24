using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UiPath.PowerShell.Robot.Models;

namespace UiPath.PowerShell.Robot.Services
{
    public interface IUiRobotService
    {
        Task<UiRobotJobDto> RunJob(RunUiRobotJobCommand input);
    }
}
