using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlModuleCalledOnNullInputOption))]
    internal sealed class SqlScriptModuleCalledOnNullInputOption : SqlScriptModuleOption<SqlModuleCalledOnNullInputOption>
        {
        #region ctor{IServiceProvider,SqlModuleCalledOnNullInputOption}
        public SqlScriptModuleCalledOnNullInputOption(IServiceProvider context,SqlModuleCalledOnNullInputOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }