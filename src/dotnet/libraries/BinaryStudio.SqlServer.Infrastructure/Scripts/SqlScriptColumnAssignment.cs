using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptColumnAssignment : SqlScriptAssignment<SqlColumnAssignment>
        {
        #region ctor{IServiceProvider,SqlColumnAssignment}
        public SqlScriptColumnAssignment(IServiceProvider context,SqlColumnAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }