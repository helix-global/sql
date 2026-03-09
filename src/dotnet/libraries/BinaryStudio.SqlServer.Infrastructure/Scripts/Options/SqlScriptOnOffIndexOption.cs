using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptOnOffIndexOption<T> : SqlScriptIndexOption<T>
        where T : SqlIndexOption
        {
        [Field] public SqlOnOffValue OnOffValue { get; }

        #region ctor{IServiceProvider,T}
        protected SqlScriptOnOffIndexOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        public override String ToString()
            {
            return $"{Phrase.ToLowerInvariant()} = {OnOffValue.ToString().ToLowerInvariant()}";
            }
        #endregion
        }
    }
