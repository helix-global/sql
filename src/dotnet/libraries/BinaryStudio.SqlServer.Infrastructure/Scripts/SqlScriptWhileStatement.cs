using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptWhileStatement : SqlScriptConditionalStatement<SqlWhileStatement>
        {
        #region ctor{IServiceProvider,SqlWhileStatement}
        public SqlScriptWhileStatement(IServiceProvider context,SqlWhileStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }