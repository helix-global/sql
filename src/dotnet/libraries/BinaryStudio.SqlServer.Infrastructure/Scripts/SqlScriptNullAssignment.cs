using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptNullAssignment : SqlScriptAssignment<SqlNullAssignment>
        {
        #region ctor{IServiceProvider,SqlNullAssignment}
        public SqlScriptNullAssignment(IServiceProvider context,SqlNullAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }