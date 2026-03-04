using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptModuleRecompileOption : SqlScriptModuleOption<SqlModuleRecompileOption>
        {
        #region ctor{IServiceProvider,SqlModuleRecompileOption}
        public SqlScriptModuleRecompileOption(IServiceProvider context,SqlModuleRecompileOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }