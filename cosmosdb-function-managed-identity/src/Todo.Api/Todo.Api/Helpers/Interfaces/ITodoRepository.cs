using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Todo.Api.Models;

namespace Todo.Api.Helpers.Interfaces
{
    public interface ITodoRepository
    {
        Task CreateTodoItem(TodoItem todoItem);
    }
}
