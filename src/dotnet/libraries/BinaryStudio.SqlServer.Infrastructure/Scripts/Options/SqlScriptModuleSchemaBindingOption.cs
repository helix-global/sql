using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlModuleSchemaBindingOption))]
    internal sealed class SqlScriptModuleSchemaBindingOption : SqlScriptModuleOption<SqlModuleSchemaBindingOption>
        {
        #region ctor{IServiceProvider,SqlModuleSchemaBindingOption}
        public SqlScriptModuleSchemaBindingOption(IServiceProvider context,SqlModuleSchemaBindingOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }