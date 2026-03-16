using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlModuleNativeCompilationOption))]
    internal sealed class SqlScriptModuleNativeCompilationOption : SqlScriptModuleOption<SqlModuleNativeCompilationOption>
        {
        #region ctor{IServiceProvider,SqlModuleNativeCompilationOption}
        public SqlScriptModuleNativeCompilationOption(IServiceProvider context,SqlModuleNativeCompilationOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }