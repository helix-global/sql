using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptModuleExecuteAsOption : SqlScriptModuleOption<SqlModuleExecuteAsOption>
        {
        #region ctor{IServiceProvider,SqlModuleExecuteAsOption}
        public SqlScriptModuleExecuteAsOption(IServiceProvider context,SqlModuleExecuteAsOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }