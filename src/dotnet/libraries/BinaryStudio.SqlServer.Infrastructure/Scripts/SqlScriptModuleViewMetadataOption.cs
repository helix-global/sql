using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptModuleViewMetadataOption : SqlScriptModuleOption<SqlModuleViewMetadataOption>
        {
        #region ctor{IServiceProvider,SqlModuleViewMetadataOption}
        public SqlScriptModuleViewMetadataOption(IServiceProvider context,SqlModuleViewMetadataOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }