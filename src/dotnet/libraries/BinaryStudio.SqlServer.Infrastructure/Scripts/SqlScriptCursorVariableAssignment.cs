using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCursorVariableAssignment))]
    internal sealed class SqlScriptCursorVariableAssignment : SqlScriptVariableAssignment<SqlCursorVariableAssignment>
        {
        #region ctor{IServiceProvider,SqlCursorVariableAssignment}
        public SqlScriptCursorVariableAssignment(IServiceProvider context,SqlCursorVariableAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }