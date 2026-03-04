using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptSelectVariableAssignmentExpression : SqlScriptSelectExpression<SqlSelectVariableAssignmentExpression>
        {
        #region ctor{IServiceProvider,SqlSelectVariableAssignmentExpression}
        public SqlScriptSelectVariableAssignmentExpression(IServiceProvider context,SqlSelectVariableAssignmentExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }