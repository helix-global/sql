using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptVariableDeclareStatement : SqlScriptDeclareStatement<SqlVariableDeclareStatement>
        {
        #region ctor{IServiceProvider,SqlVariableDeclareStatement}
        public SqlScriptVariableDeclareStatement(IServiceProvider context,SqlVariableDeclareStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }