using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptModuleInlineOption : SqlScriptModuleOption<SqlModuleInlineOption>
        {
        #region ctor{IServiceProvider,SqlModuleInlineOption}
        public SqlScriptModuleInlineOption(IServiceProvider context,SqlModuleInlineOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }